#!/usr/bin/env python3
"""Require changed website dictionary strings in every active site locale."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import subprocess
import sys
from collections import Counter
from pathlib import Path, PurePosixPath
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[2]
I18N = PurePosixPath("site/src/i18n")
GROUPS = {"ui", "games", "play"}
NON_COPY_FIELDS = {"href", "icon", "id"}
PLURAL_FORMS = {"zero", "one", "two", "few", "many", "other"}
EXPECTED_ROUTE_COUNT = 190  # English plus registry codes and active site variants.
PLACEHOLDER = re.compile(r"\{[\w-]+(?:\|[\w-]+)?\}")
TAG = re.compile(r"</?\s*([a-z][a-z0-9]*)\b[^>]*>", re.IGNORECASE)
HREF = re.compile(r"\bhref\s*=\s*([\"'])(.*?)\1", re.IGNORECASE)


def required_routes(repo_root: Path = REPO_ROOT) -> list[str]:
    """Return English and all registered/active non-English site locales."""
    checker_path = repo_root / "site/scripts/check-guide-coverage.py"
    spec = importlib.util.spec_from_file_location("guide_coverage_for_site_copy", checker_path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load locale registry from {checker_path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    routes = ["en", *module.required_locales(repo_root)]
    if len(routes) != EXPECTED_ROUTE_COUNT or len(routes) != len(set(routes)):
        raise ValueError(
            f"expected {EXPECTED_ROUTE_COUNT} unique English and translated routes, found {len(routes)}"
        )
    return routes


def is_plural(value: Any) -> bool:
    return isinstance(value, dict) and "other" in value and set(value).issubset(PLURAL_FORMS)


def fixed_messages(data: Any, group: str) -> dict[tuple[str | int, ...], Any]:
    """Flatten fixed messages; language-specific ``play.content`` is excluded."""
    messages: dict[tuple[str | int, ...], Any] = {}

    def walk(value: Any, path: tuple[str | int, ...]) -> None:
        if group == "play" and path[:1] == ("content",):
            return
        if isinstance(value, str):
            if path and path[-1] not in NON_COPY_FIELDS and value.strip():
                messages[path] = value
            return
        if isinstance(value, list):
            for index, item in enumerate(value):
                walk(item, (*path, index))
            return
        if is_plural(value):
            if path:
                messages[path] = value
            return
        if isinstance(value, dict):
            for key, item in value.items():
                if key.startswith("_") or key in NON_COPY_FIELDS:
                    continue
                walk(item, (*path, key))

    walk(data, ())
    return messages


def changed_message_paths(before: Any, after: Any, group: str) -> set[tuple[str | int, ...]]:
    old_messages = fixed_messages(before, group)
    new_messages = fixed_messages(after, group)
    return {
        path
        for path in old_messages.keys() | new_messages.keys()
        if old_messages.get(path) != new_messages.get(path)
    }


def changed_i18n_files(repo_root: Path, base: str, head: str) -> list[PurePosixPath]:
    result = subprocess.run(
        [
            "git",
            "diff",
            "--name-only",
            "--no-renames",
            f"{base}...{head}",
            "--",
            str(I18N),
        ],
        cwd=repo_root,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode:
        raise ValueError(result.stderr.strip() or "git diff failed")

    files = []
    for raw in result.stdout.splitlines():
        path = PurePosixPath(raw)
        try:
            relative = path.relative_to(I18N)
        except ValueError:
            continue
        if len(relative.parts) == 2 and relative.parts[0] in GROUPS and relative.suffix == ".json":
            files.append(path)
    return sorted(files)


def load_json_at(repo_root: Path, revision: str, path: PurePosixPath) -> dict[str, Any] | None:
    result = subprocess.run(
        ["git", "show", f"{revision}:{path.as_posix()}"],
        cwd=repo_root,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode:
        return None
    try:
        data = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise ValueError(f"{revision}:{path}: invalid JSON: {error}") from error
    if not isinstance(data, dict):
        raise ValueError(f"{revision}:{path}: dictionary root must be an object")
    return data


def _html_tags(value: str) -> list[tuple[bool, str]]:
    return [(match.group(0).lstrip().startswith("</"), match.group(1).lower()) for match in TAG.finditer(value)]


def _link_targets(value: str) -> list[str]:
    return [match.group(2) for match in HREF.finditer(value)]


def message_shape_errors(source: Any, translation: Any) -> list[str]:
    if isinstance(source, str):
        if not isinstance(translation, str) or not translation.strip():
            return ["missing or empty text"]
        errors = []
        checks = (
            ("placeholders", Counter(PLACEHOLDER.findall(source)), Counter(PLACEHOLDER.findall(translation))),
            ("HTML tags", Counter(_html_tags(source)), Counter(_html_tags(translation))),
            ("link targets", Counter(_link_targets(source)), Counter(_link_targets(translation))),
        )
        for label, expected, actual in checks:
            if expected != actual:
                errors.append(f"{label} differ")
        return errors
    if is_plural(source):
        if not is_plural(translation):
            return ['plural forms need an "other" branch']
        return [
            f"{form}: {error}"
            for form, value in translation.items()
            for error in message_shape_errors(source["other"], value)
        ]
    return ["unsupported source message shape"]


def missing_copy_errors(
    repo_root: Path,
    group: str,
    routes: list[str],
    paths: set[tuple[str | int, ...]],
    source_messages: dict[tuple[str | int, ...], Any],
) -> list[str]:
    errors: list[str] = []
    for code in routes:
        relative = I18N / group / f"{code}.json"
        target_path = repo_root / relative
        if not target_path.is_file():
            errors.append(f"{group}/{code}: missing {relative.as_posix()}")
            continue
        try:
            target_data = json.loads(target_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            errors.append(f"{group}/{code}: invalid or unreadable JSON: {error}")
            continue
        if not isinstance(target_data, dict):
            errors.append(f"{group}/{code}: dictionary root must be an object")
            continue

        target_messages = fixed_messages(target_data, group)
        invalid = []
        for path in sorted(paths, key=lambda item: ".".join(map(str, item))):
            for error in message_shape_errors(source_messages[path], target_messages.get(path)):
                invalid.append(f"{'.'.join(map(str, path))}: {error}")
        if invalid:
            preview = "; ".join(invalid[:5])
            remainder = f"; (+{len(invalid) - 5} more)" if len(invalid) > 5 else ""
            errors.append(
                f"{group}/{code}: {len(invalid)} changed strings missing or structurally invalid: "
                f"{preview}{remainder}"
            )
    return errors


def check_changed_copy(repo_root: Path, base: str, head: str) -> tuple[int, list[str]]:
    routes = required_routes(repo_root)
    files = changed_i18n_files(repo_root, base, head)
    if not files:
        return 0, []

    by_group: dict[str, dict[str, set[tuple[str | int, ...]]]] = {}
    errors: list[str] = []
    for path in files:
        group = path.parts[3]
        code = path.stem
        if code not in routes:
            errors.append(f"{group}/{code}: not in the active site locale list")
            continue
        before = load_json_at(repo_root, base, path) or {}
        after = load_json_at(repo_root, head, path)
        if after is None:
            errors.append(f"{group}/{code}: deleting a locale dictionary is not supported")
            continue
        by_group.setdefault(group, {})[code] = changed_message_paths(before, after, group)

    changed_count = 0
    for group, per_locale in by_group.items():
        source_path = I18N / group / "en.json"
        current_source = load_json_at(repo_root, head, source_path)
        if current_source is None:
            errors.append(f"{group}/en: English source is missing")
            continue
        previous_source = load_json_at(repo_root, base, source_path) or {}
        source_messages = fixed_messages(current_source, group)
        old_source_messages = fixed_messages(previous_source, group)
        candidates = set().union(*per_locale.values()) if per_locale else set()
        removed = set(old_source_messages) - set(source_messages)
        orphaned = {
            path
            for code, paths in per_locale.items()
            if code != "en"
            for path in paths - set(source_messages) - removed
        }
        if orphaned:
            preview = ", ".join(".".join(map(str, path)) for path in sorted(orphaned)[:5])
            errors.append(f"{group}: changed strings absent from English: {preview}")
        changed = candidates & set(source_messages)
        if not changed:
            continue
        changed_count += len(changed)
        errors.extend(missing_copy_errors(repo_root, group, routes, changed, source_messages))
    return changed_count, errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, help="base commit SHA for the site change")
    parser.add_argument("--head", required=True, help="head commit SHA for the site change")
    args = parser.parse_args(argv)
    try:
        changed_count, errors = check_changed_copy(REPO_ROOT, args.base, args.head)
    except (ImportError, OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        print(f"ERROR site dictionary translation coverage: {error}", file=sys.stderr)
        return 1
    if errors:
        for error in errors[:60]:
            print(f"ERROR {error}")
        if len(errors) > 60:
            print(f"... and {len(errors) - 60} more errors")
        return 1
    if changed_count:
        print(f"{changed_count} changed site strings are present in all {EXPECTED_ROUTE_COUNT} routes.")
    else:
        print("No changed site dictionary strings; translation coverage check skipped.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
