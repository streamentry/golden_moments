# Engineering research register

Reviewed 2026-10-18 for Golden Moments, against repository base
`499f586912ba18c1cceafccfd47fccd17ad544a5`. Sources below were opened during this
research. Their publication dates differ; "2026 guidance" does not mean every
practice or article was first published in 2026. Recheck changing API details
against the pinned SDK before implementation.

This is an adaptation with attribution, not a copied rules template. Public
sources establish platform behavior and engineering recommendations; they do
not establish this app's test results, market demand, clinical value, or legal
clearance. Specific local guardrails are maintainer decisions.

## Flutter and Dart

| ID | Primary source | Applied here |
| --- | --- | --- |
| F1 | [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations) | Separate UI/data responsibilities, inject effects, avoid an unnecessary domain layer; preserve the existing state-management approach |
| F2 | [Effective Dart: Usage](https://dart.dev/effective-dart/usage) | Clear async ownership, typed boundaries, and deliberate error handling |
| F3 | [use_build_context_synchronously](https://dart.dev/tools/linter-rules/use_build_context_synchronously) | Check the correct mounted context after asynchronous gaps |
| F4 | [Flutter accessibility](https://docs.flutter.dev/ui/accessibility) and [accessibility testing](https://docs.flutter.dev/ui/accessibility/accessibility-testing) | Semantics, contrast, large touch targets, scaling, automated guidelines and real assistive-technology checks |
| F5 | [Testing Flutter apps](https://docs.flutter.dev/testing/overview) | Unit/widget/integration coverage; native-dialog limitations of integration_test |
| F6 | [Performance best practices](https://docs.flutter.dev/perf/best-practices) | Measure before optimizing; control rebuilding/rendering and validate performance on target devices |
| F7 | [image_picker maintained documentation](https://pub.dev/packages/image_picker) | Explicit picker use, platform caveats, Android lost-data recovery, and real-device HEIC validation |
| F8 | [AI rules for Flutter and Dart](https://docs.flutter.dev/ai/ai-rules) | Adapt rules to the repository and client's instruction-loading mechanism |
| F9 | [Dart and Flutter MCP server](https://docs.flutter.dev/ai/mcp-server) | Optional local diagnostics/symbol/test/runtime tooling with a normal CLI fallback |

## Agent-assisted engineering

| ID | Primary source | Applied here |
| --- | --- | --- |
| A1 | [OpenAI: Harness engineering](https://openai.com/index/harness-engineering/) (2026-02-11) | Short instruction map, versioned repository knowledge, observable checks, isolated worktrees |
| A2 | [OpenAI: AGENTS.md discovery](https://developers.openai.com/codex/guides/agents-md) | Canonical filename and scoped guidance; verify actual client loading rather than assuming it |
| A3 | [Anthropic: Claude Code best practices](https://code.claude.com/docs/en/best-practices) | Verifiable tasks, scoped context, review, cautious permissions, and optional parallel work |
| A4 | [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) (2025-11-26) | Small complete increments, progress tied to Git, and explicit handoffs instead of premature completion |
| A5 | [OpenAI: Custom Code Review rules](https://developers.openai.com/blog/custom-code-review-rules-for-codex) (2026-07-20) | Consequential scoped invariants, safe paths, useful findings, and violation/safe/unrelated evaluation cases |
| P1 | [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) | Accurate metadata, real functionality/screenshots, privacy review, and caution around medical claims |

## Deliberate adaptations and exclusions

- Preserve Bloc/Cubit and local state rather than mandating an MVVM/Riverpod
  migration. Flutter explicitly frames architecture as adaptable recommendations.
- Prefer existing native/local capabilities. MCP and new testing harnesses are
  optional tooling decisions, not shipping dependencies or setup prerequisites.
- Do not copy throughput claims, particular model names, agent-swarm recipes,
  giant rule files, or automatic-merge policies from vendor examples.
- Use the existing workboard and release-status schema instead of a new agent
  database, backend, or competing progress file.
- Treat AI development assistance separately from user-facing AI features.
- 48-logical-pixel controls, 200% scaling checks, and bounded photo handling are
  local acceptance choices, not evidence of suitability for every participant.
- Root metadata limits and exact copy are checked against the canonical JSON.
  Research does not turn unmeasured ASO hypotheses into proven rankings.

## Maintenance

Check these sources when upgrading the SDK/toolchain, enabling a new agent
client, or changing a sensitive boundary. Replace stale instructions in the same
PR as the related change. Test representative agent behavior before keeping
large rule additions. Never mark native, privacy, or clinical checks complete
because documentation has been improved.
