/// Off in every shipped build. Pilot builds opt in with
/// `--dart-define=GM_EXPERIMENTS=true`. An experiment stays behind this flag
/// until observed use chooses it (docs/specs/senior-first/roadmap.md, R2);
/// a prototype that does not earn its place is removed, not promoted.
const bool experimentsEnabled = bool.fromEnvironment('GM_EXPERIMENTS');
