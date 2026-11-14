# OpenCode translation goal

A ready-to-paste `/goal` for a local Claude Code session that closes the
remaining language gap with OpenCode as the translator. The steps and checks it
relies on are in [Translating with OpenCode](opencode-translation.md).

Before pasting:

1. `git checkout main && git pull`.
2. Run `opencode models` and choose your strongest paid model for `MODEL`.
3. Change the per-batch spending stop (`$25` below) to what you accept.
4. Translate one language first, read your OpenCode usage, then multiply by the
   gap before running the rest. Rough guess: the English guides are about
   215k tokens per language, and non-Latin scripts can cost 2 to 3 times that
   on output.

## Goal text

```text
/goal Close the Golden Moments translation gap. OpenCode translates, a Claude sub-agent reviews.

Setup, once:
- Start from an up-to-date main and create branch l10n/opencode-1.
- Read AGENTS.md, docs/engineering/opencode-translation.md and docs/engineering/localization.md.
- Run `opencode models`. Set MODEL to my strongest paid model. Confirm flutter --version matches .fvmrc.

App text, 5 languages per batch:
1. Run `python3 scripts/opencode_translate.py gaps`. Pick the next 5 languages with no app text, most speakers first. Skip the dropped languages in the doc's "Known traps" unless MODEL is clearly stronger than the model that failed them.
2. Translate up to 5 at once as background shells: `python3 scripts/opencode_translate.py app <code> "<Language (script)>" -m $MODEL`.
3. Review each language with a Claude sub-agent, never the model that translated it. Answer SHIPPABLE or NOT SHIPPABLE as unreviewed machine translation. Check for wrong meaning, flipped negation, made-up words, US helpline numbers and safety wording.
   NOT SHIPPABLE: delete its files and add it to the doc's dropped list with the reason.
4. Register each shippable language as the doc says: register_language.py, dart format, LOW_CONFIDENCE_LOCALES. Then run `app` again so the store draft is written.
5. Run every check in the doc. Fix the cause; never weaken a test or a checker.
6. Commit and push the branch, without force. Open one PR per batch titled "l10n: <codes> (machine-translated, unreviewed)".
   Don't merge and don't wait on CI. Before opening the next PR, check the last one and fix any failures.

Guides, after the app text, 3 to 5 languages per PR:
- Run `python3 scripts/opencode_translate.py guides <code> "<Language>" -m $MODEL`.
- Review at least 5 guides per language, health guides first. Revert a language's guides if the health wording is wrong.

Special cases:
- Guarani: fix the missing Guarani entry in lib/l10n/language_names.dart before adding it.
- South Azerbaijani: needs a real play dictionary. If you can't find one, record it as blocked.

Done when `gaps` shows no missing app language and no missing guide, except languages recorded in the doc as dropped or blocked, each with a reason.

Stop and ask me if:
- a batch costs more than $25,
- the same language fails review twice, or
- a check fails on main before my change.

Never:
- put personal data, secrets or local paths in OpenCode prompts,
- mark a translation as reviewed,
- force push or merge.
```

## Limits to keep in mind

- A Claude review of a low-resource language catches large errors but not
  reliably wrong health wording; only a native speaker can clear that.
- The gap on 2026-11-14 was 72 languages without app text and about 4,200 guide
  files across 84 languages. Guides are the bulk of the cost; consider doing
  them first for the languages with the most speakers.
