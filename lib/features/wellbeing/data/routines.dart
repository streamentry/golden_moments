/// Suggested routines for the day (Activity Planner). Suggestions only: the
/// person or caregiver chooses what fits and skips the rest.
///
/// Each step is either an existing place in the app or a plain suggestion
/// with no action. Nothing here measures, scores or times anything.
enum PlanTime { morning, afternoon, evening }

enum PlanFor { me, someoneICare }

enum RoutineItem {
  /// Opens the Daily moment.
  dailyMoment,

  /// Opens the picture matching game.
  matchingGame,

  /// Opens "Look at pictures together".
  lookTogether,

  /// Plain suggestions, with no action.
  drinkWater,
  stepOutside,
  teaTogether,
  callSomeone,
  dimLights,
  planTogether,
  keepQuiet;

  /// Whether tapping the step opens a page in the app.
  bool get opens => switch (this) {
    dailyMoment || matchingGame || lookTogether => true,
    _ => false,
  };
}

/// The three steps for [time] and [who], in the order shown.
List<RoutineItem> routineFor(PlanTime time, PlanFor who) {
  return switch ((time, who)) {
    (PlanTime.morning, PlanFor.me) => const [
      RoutineItem.drinkWater,
      RoutineItem.dailyMoment,
      RoutineItem.matchingGame,
    ],
    (PlanTime.morning, PlanFor.someoneICare) => const [
      RoutineItem.planTogether,
      RoutineItem.dailyMoment,
      RoutineItem.lookTogether,
    ],
    (PlanTime.afternoon, PlanFor.me) => const [
      RoutineItem.stepOutside,
      RoutineItem.callSomeone,
      RoutineItem.lookTogether,
    ],
    (PlanTime.afternoon, PlanFor.someoneICare) => const [
      RoutineItem.teaTogether,
      RoutineItem.matchingGame,
      RoutineItem.dailyMoment,
    ],
    (PlanTime.evening, PlanFor.me) => const [
      RoutineItem.dimLights,
      RoutineItem.dailyMoment,
      RoutineItem.lookTogether,
    ],
    (PlanTime.evening, PlanFor.someoneICare) => const [
      RoutineItem.keepQuiet,
      RoutineItem.lookTogether,
      RoutineItem.dailyMoment,
    ],
  };
}
