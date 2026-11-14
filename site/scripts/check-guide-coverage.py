#!/usr/bin/env python3
"""Require language copies for every changed English guide before a site build."""

from __future__ import annotations

import argparse
import importlib.util
import re
import subprocess
import sys
from pathlib import Path, PurePosixPath
from typing import Iterable

ROOT = Path(__file__).resolve().parents[2]
GUIDES = PurePosixPath("site/src/content/guides")
TRANSLATIONS = PurePosixPath("site/src/content/guides-i18n")


def _translator(repo_root: Path):
    path = repo_root / "site/scripts/agy_translate.py"
    spec = importlib.util.spec_from_file_location("agy_translate_for_coverage", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load language catalog from {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    module.CSV = repo_root / "docs/languages.csv"
    module.I18N = repo_root / "site/src/i18n"
    return module


def required_locales(repo_root: Path = ROOT) -> list[str]:
    """Return every non-English registry code and active site locale."""
    translator = _translator(repo_root)
    registry_codes = [item["code"] for item in translator.languages()]
    locale_source = (repo_root / "site/src/i18n/locales.ts").read_text(encoding="utf-8")
    declarations = re.findall(r"^\s*\{ code: '([^']+)', prefix: '", locale_source, re.MULTILINE)
    if len(declarations) != len(set(declarations)):
        raise ValueError("duplicate site locale code in site/src/i18n/locales.ts")
    metadata = translator.locale_codes()
    missing_metadata = sorted(set(registry_codes) - set(metadata))
    if missing_metadata:
        raise ValueError(f"language registry codes lack site locale metadata: {', '.join(missing_metadata)}")
    codes = list(dict.fromkeys([*registry_codes, *declarations]))
    if "en" not in codes:
        raise ValueError("English must be present in the language registry")
    return sorted(code for code in codes if code != "en")


def guide_slugs(changed_paths: Iterable[str]) -> list[str]:
    """Keep only added or changed English Markdown guide paths."""
    slugs: set[str] = set()
    for raw in changed_paths:
        path = PurePosixPath(raw)
        try:
            relative = path.relative_to(GUIDES)
        except ValueError:
            continue
        if relative.suffix != ".md":
            continue
        if any(part in {".", ".."} for part in relative.parts):
            raise ValueError(f"invalid English guide path: {raw}")
        slugs.add(relative.with_suffix("").as_posix())
    return sorted(slugs)


def changed_paths(repo_root: Path, base: str, head: str) -> list[str]:
    if not base or not head:
        raise ValueError("both base and head commit SHAs are required")
    result = subprocess.run(
        ["git", "diff", "--name-only", "--diff-filter=ACMRT", base, head],
        cwd=repo_root,
        check=True,
        capture_output=True,
        text=True,
    )
    return result.stdout.splitlines()


def _guide_checker(repo_root: Path):
    path = repo_root / "site/scripts/check-guide-translation.py"
    spec = importlib.util.spec_from_file_location("guide_translation_validator", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load guide validator from {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def validate_translations(repo_root: Path, slugs: Iterable[str], locales: Iterable[str], checker) -> tuple[list[str], int]:
    errors = []
    warning_count = 0
    for code in locales:
        for slug in slugs:
            page_errors, page_warnings = checker.check(code, slug)
            errors.extend(f"{code}/{slug}: {error}" for error in page_errors)
            warning_count += len(page_warnings)
    return errors, warning_count


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, help="base commit SHA for the site change")
    parser.add_argument("--head", required=True, help="head commit SHA for the site change")
    args = parser.parse_args(argv)

    try:
        slugs = guide_slugs(changed_paths(ROOT, args.base, args.head))
        if not slugs:
            print("No changed English guides; translation coverage check skipped.")
            return 0
        locales = required_locales(ROOT)
        checker = _guide_checker(ROOT)
        errors, warning_count = validate_translations(ROOT, slugs, locales, checker)
    except (ImportError, OSError, RuntimeError, ValueError, subprocess.CalledProcessError) as error:
        print(f"ERROR guide translation coverage: {error}", file=sys.stderr)
        return 1

    if errors:
        for item in errors[:100]:
            print(f"ERROR {item}")
        if len(errors) > 100:
            print(f"... and {len(errors) - 100} more errors")
        print(
            f"Guide translation validation failed: {len(errors)} errors for "
            f"{len(slugs)} changed guide(s) across {len(locales)} locales."
        )
        return 1

    print(
        f"Guide translation validation passed: {len(slugs)} changed guide(s), "
        f"{len(locales)} locales, {warning_count} non-fatal warnings."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
