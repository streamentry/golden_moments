#!/usr/bin/env python3
"""Require changed app ARB strings in every language in docs/languages.csv.

This checks coverage, not translation quality. `check_arb.py` and Flutter's
localization generator remain responsible for ARB structure and placeholders.

    python3 scripts/check_app_translation_coverage.py --base BASE --head HEAD
"""
from __future__ import annotations

import argparse
import csv
import json
import subprocess
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
ARB_DIR = Path("lib/l10n/arb")
EXPECTED_LANGUAGE_COUNT = 185


def language_codes(path: Path) -> list[str]:
    with path.open(encoding="utf-8-sig", newline="") as source:
        rows = csv.reader(source)
        try:
            header = next(rows)
        except StopIteration as error:
            raise ValueError(f"{path}: empty language registry") from error
        normalized_header = [field.strip() for field in header]
        try:
            code_column = normalized_header.index("Locale code")
        except ValueError as error:
            raise ValueError(f"{path}: missing 'Locale code' column") from error
        codes = [
            row[code_column].strip()
            for row in rows
            if len(row) > code_column and row[code_column].strip()
        ]

    if len(codes) != len(set(codes)):
        raise ValueError(f"{path}: duplicate language codes")
    if len(codes) != EXPECTED_LANGUAGE_COUNT:
        raise ValueError(
            f"{path}: expected {EXPECTED_LANGUAGE_COUNT} unique codes, found {len(codes)}"
        )
    if "en" not in codes:
        raise ValueError(f"{path}: English code 'en' is missing")
    return codes


def arb_path(code: str) -> Path:
    return ARB_DIR / f"app_{code.replace('-', '_')}.arb"


def message_values(data: dict[str, Any]) -> dict[str, Any]:
    return {key: value for key, value in data.items() if not key.startswith("@")}


def changed_message_keys(before: dict[str, Any], after: dict[str, Any]) -> set[str]:
    old_messages = message_values(before)
    new_messages = message_values(after)
    return {
        key
        for key in old_messages.keys() | new_messages.keys()
        if old_messages.get(key) != new_messages.get(key)
    }


def orphaned_translation_keys(
    changed_keys: set[str],
    previous_english_keys: set[str],
    current_english_keys: set[str],
) -> set[str]:
    removed_from_english = previous_english_keys - current_english_keys
    return changed_keys - current_english_keys - removed_from_english


def changed_arb_paths(root: Path, base: str, head: str) -> list[Path]:
    completed = subprocess.run(
        [
            "git",
            "diff",
            "--name-only",
            "--no-renames",
            f"{base}...{head}",
            "--",
            str(ARB_DIR),
        ],
        cwd=root,
        check=False,
        capture_output=True,
        text=True,
    )
    if completed.returncode:
        detail = completed.stderr.strip() or "git diff failed"
        raise ValueError(detail)
    return sorted(
        Path(line)
        for line in completed.stdout.splitlines()
        if line.startswith(f"{ARB_DIR}/app_") and line.endswith(".arb")
    )


def load_arb_at(root: Path, revision: str, path: Path) -> dict[str, Any] | None:
    completed = subprocess.run(
        ["git", "show", f"{revision}:{path.as_posix()}"],
        cwd=root,
        check=False,
        capture_output=True,
        text=True,
    )
    if completed.returncode:
        return None
    try:
        data = json.loads(completed.stdout)
    except json.JSONDecodeError as error:
        raise ValueError(f"{revision}:{path}: invalid JSON: {error}") from error
    if not isinstance(data, dict):
        raise ValueError(f"{revision}:{path}: ARB root must be an object")
    return data


def missing_copies(
    root: Path,
    codes: list[str],
    keys: set[str],
) -> list[str]:
    errors: list[str] = []
    for code in codes:
        path = root / arb_path(code)
        if not path.is_file():
            errors.append(f"{code}: missing {arb_path(code).as_posix()}")
            continue
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as error:
            errors.append(f"{code}: invalid ARB JSON: {error}")
            continue
        if not isinstance(data, dict):
            errors.append(f"{code}: ARB root must be an object")
            continue
        expected_locale = path.stem.removeprefix("app_")
        if data.get("@@locale") != expected_locale:
            errors.append(
                f"{code}: @@locale is {data.get('@@locale')!r}, expected {expected_locale!r}"
            )
        messages = message_values(data)
        absent = sorted(
            key
            for key in keys
            if not isinstance(messages.get(key), str) or not messages[key].strip()
        )
        if absent:
            preview = ", ".join(absent[:5])
            remainder = f" (+{len(absent) - 5} more)" if len(absent) > 5 else ""
            errors.append(f"{code}: {len(absent)} changed keys missing or empty: {preview}{remainder}")
    return errors


def check_changed_copy(root: Path, base: str, head: str) -> tuple[set[str], list[str]]:
    codes = language_codes(root / "docs/languages.csv")
    paths = changed_arb_paths(root, base, head)
    if not paths:
        return set(), []

    code_by_path = {arb_path(code): code for code in codes}
    errors: list[str] = []
    changed_by_code: dict[str, set[str]] = {}
    for path in paths:
        code = code_by_path.get(path)
        if code is None:
            errors.append(f"{path.as_posix()}: app locale is not in docs/languages.csv")
            continue
        before = load_arb_at(root, base, path) or {}
        after = load_arb_at(root, head, path)
        if after is None:
            errors.append(f"{path.as_posix()}: deleting an app ARB file is not supported")
            continue
        changed_by_code[code] = changed_message_keys(before, after)

    english_path = arb_path("en")
    english = load_arb_at(root, head, english_path)
    if english is None:
        errors.append(f"{english_path.as_posix()}: English source is missing at {head}")
        return set(), errors

    english_keys = set(message_values(english))
    previous_english = load_arb_at(root, base, english_path) or {}
    previous_english_keys = set(message_values(previous_english))
    for code, keys in changed_by_code.items():
        if code == "en":
            continue
        orphaned = orphaned_translation_keys(keys, previous_english_keys, english_keys)
        if orphaned:
            errors.append(
                f"{code}: changed keys absent from English source: {', '.join(sorted(orphaned)[:5])}"
            )

    changed = set().union(*changed_by_code.values()) if changed_by_code else set()
    # Removing an English key removes the user-facing string. Any translated
    # remnants are no longer shipped, so only keys still present in English
    # need coverage checks.
    changed.intersection_update(english_keys)
    if not changed:
        return changed, errors
    errors.extend(missing_copies(root, codes, changed))
    return changed, errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, help="base commit for the change")
    parser.add_argument("--head", required=True, help="head commit for the change")
    args = parser.parse_args(argv)
    try:
        keys, errors = check_changed_copy(ROOT, args.base, args.head)
    except (OSError, ValueError) as error:
        print(f"App copy coverage check failed: {error}", file=sys.stderr)
        return 1

    if errors:
        print("App copy is not present in all 185 registered languages:")
        for error in errors[:40]:
            print(f"- {error}")
        if len(errors) > 40:
            print(f"- and {len(errors) - 40} more errors")
        return 1
    if keys:
        print(f"{len(keys)} changed app strings are present in all 185 registered languages.")
    else:
        print("No changed app ARB strings; app copy coverage check skipped.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
