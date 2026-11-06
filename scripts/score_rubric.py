#!/usr/bin/env python3
"""Scores docs/plan/scoring-rubric.md from repository evidence alone.

    python3 scripts/score_rubric.py            # print the scores as JSON

No person, device, store or user data is used. Each criterion has a fixed
formula written below; none is tuned to reach a target. A score says what the
repository shows, not whether the app is the best. Criteria that need a human
or real-use evidence have a ceiling, and that ceiling is part of the formula.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NEGATION = re.compile(r"\b(not|no|never|nothing|doesn't|does not|isn't|is not|without|cannot)\b", re.I)


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def unnegated_hits(pattern: re.Pattern, texts: list[str]) -> int:
    """Matches that assert something: not a question, not negated, not quoted.

    A question ("Do games prevent dementia?") asserts nothing. A phrase
    introduced by "claims that" names a claim the app does not make. Both are
    skipped, and every other match must have no negation in its sentence.
    """
    hits = 0
    for text in texts:
        for match in pattern.finditer(text):
            window = text[max(0, match.start() - 60) : match.start()]
            sentence = re.split(r"[.!?;]", window)[-1]
            if re.match(r"[^.!;\n<]{0,40}\?", text[match.end() :]):
                continue  # the sentence is a question
            if re.search(r"claims? that\b", window, re.I):
                continue
            if NEGATION.search(sentence):
                continue
            hits += 1
    return hits


def arb_values(lang_file: str) -> list[str]:
    import json as _json

    data = _json.loads(read(f"lib/l10n/arb/{lang_file}"))
    return [v for k, v in data.items() if not k.startswith("@") and isinstance(v, str)]


def site_strings() -> list[str]:
    texts: list[str] = []
    for path in (ROOT / "site/src/i18n").rglob("*.json"):
        texts.append(path.read_text(encoding="utf-8"))
    for path in (ROOT / "site/src/content").rglob("*.md"):
        texts.append(path.read_text(encoding="utf-8"))
    return texts


def score_all() -> dict:
    results: dict[str, dict] = {}

    # 1. No prevention or treatment claims (ceiling 10). Each unnegated claim costs 2.
    claim = re.compile(
        r"\b(prevents?|protects? against|cures?|reverses?|slows? (down )?|lowers? your risk|"
        r"reduces? (your )?risk of)\b[^.]{0,30}\b(dementia|alzheimer)",
        re.I,
    )
    # Scope: the app's own UI copy (all ARB files) and the site's UI dictionaries.
    # Guide articles are excluded: they quote and explain research, which a
    # pattern cannot tell apart from a claim.
    texts = [
        v for f in sorted((ROOT / "lib/l10n/arb").glob("app_*.arb"))
        for v in arb_values(f.name)
    ] + [p.read_text(encoding="utf-8") for p in (ROOT / "site/src/i18n/ui").glob("*.json")]
    hits = unnegated_hits(claim, texts)
    results["1_no_claims"] = {"score": max(0.0, 10 - 2 * hits), "hits": hits}

    # 2. Gentle play: no clock, score, streak, countdown in English UI text (ceiling 10).
    # "move" as a verb is ordinary speech; the rule is about a move counter.
    pressure = re.compile(r"\b(score|scores|streak|countdown|timer|points?|move count|moves made|seconds?|hurry|timed|faster)\b", re.I)
    en = arb_values("app_en.arb")
    hits = unnegated_hits(pressure, en)
    results["2_gentle_play"] = {"score": max(0.0, 10 - hits), "hits": hits}

    # 3. Accessibility checks present in the repo (6 checks, equal weight).
    tests = "\n".join(p.read_text(encoding="utf-8") for p in (ROOT / "test").rglob("*.dart"))
    checks = {
        "text_scale_200": bool(re.search(r"textScaler|200%|TextScaler", tests)),
        "tap_target_minimum": bool(re.search(r"gmTargetMin|48", tests)),
        "semantics_labels": bool(re.search(r"bySemanticsLabel|Semantics\(", tests)),
        "high_contrast_setting": (ROOT / "lib/features/gentle_activities/data/high_contrast_setting.dart").exists(),
        "high_contrast_contrast_test": (ROOT / "test/design_system_high_contrast_test.dart").exists(),
        "screen_reader_hidden_tiles": bool(re.search(r"hidden|Hidden", tests)),
    }
    results["3_accessibility"] = {"score": round(10 * sum(checks.values()) / len(checks), 1), "checks": checks}

    # 4. Content breadth: picture packs, 12 packs = 10 (ceiling 10).
    packs = len(json.loads(read("assets/data/packs_index.json")).get("packs", {}))
    results["4_content"] = {"score": round(min(10.0, 10 * packs / 12), 1), "packs": packs}

    # 5. Languages: share of app languages with every English key (ceiling 8: translation quality is not measured).
    en_keys = {k for k in json.loads(read("lib/l10n/arb/app_en.arb")) if not k.startswith("@")}
    files = [f for f in sorted((ROOT / "lib/l10n/arb").glob("app_*.arb")) if f.name not in ("app_en.arb", "app_pt.arb", "app_zh.arb")]
    complete = sum(1 for f in files if en_keys <= {k for k in json.loads(f.read_text(encoding="utf-8")) if not k.startswith("@")})
    coverage = complete / len(files)
    results["5_languages"] = {"score": round(8 * coverage, 1), "complete": complete, "languages": len(files)}

    # 6. Website guides: share of site languages with all 40 guides (English counts as one).
    sections = [p for p in (ROOT / "site/src/content/guides").rglob("*.md")]
    english_guides = len(sections)
    langs = [p.name for p in (ROOT / "site/src/content/guides-i18n").iterdir() if p.is_dir()]
    per_lang = [min(1.0, len(list((ROOT / f"site/src/content/guides-i18n/{l}").rglob("*.md"))) / english_guides) for l in langs]
    locales = re.findall(r"\{ code: '([^']+)', prefix: '[^']*'", read("site/src/i18n/locales.ts"))
    site_languages = len(locales)  # every site language, including English and those with no guides
    # Languages with no guide folder count as zero, so the denominator is all of them.
    coverage_site = (sum(per_lang) + 1.0) / site_languages
    results["6_website_guides"] = {"score": round(10 * coverage_site, 1), "site_languages": site_languages, "english_guides": english_guides}

    # 7. Privacy: no analytics, ads, crash or cloud SDK in the app's dependencies (10 or 0).
    pubspec = read("pubspec.yaml").lower()
    banned = ["firebase", "analytics", "sentry", "crashlytics", "admob", "facebook", "mixpanel", "amplitude"]
    found = [b for b in banned if b in pubspec]
    results["7_privacy"] = {"score": 0.0 if found else 10.0, "found": found}

    # 8. Price: no in-app purchase or subscription SDK in the app (10 or 0).
    paid = ["in_app_purchase", "purchases_flutter", "revenuecat", "adapty"]
    found = [p for p in paid if p in pubspec]
    results["8_price"] = {"score": 0.0 if found else 10.0, "found": found}

    # 9. Design consistency (a proxy for taste, ceiling 7): share of DESIGN.md colour tokens that have a Dart constant.
    design = read("DESIGN.md")
    colors = re.findall(r'^  ([a-z0-9-]+): "#([0-9A-Fa-f]{6})"', design, re.M)
    dart = read("lib/design_system.dart").upper()
    matched = sum(1 for _, hexv in colors if hexv.upper() in dart)
    results["9_design_consistency"] = {"score": round(7 * matched / len(colors), 1), "tokens": len(colors), "matched": matched}

    # 10. Evidence of effect (ceiling 5 until measured use exists; capped at 0 without any result file).
    studies = [p for p in (ROOT / "docs").rglob("*.md") if re.search(r"(usability|pilot|study)[-_]?results?", p.name, re.I)]
    results["10_evidence"] = {"score": 0.0 if not studies else 5.0, "result_files": [str(p.relative_to(ROOT)) for p in studies]}

    total = round(sum(r["score"] for r in results.values()), 1)
    return {"total": total, "out_of": 100, "criteria": results}


def main() -> int:
    result = score_all()
    print(json.dumps(result, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
