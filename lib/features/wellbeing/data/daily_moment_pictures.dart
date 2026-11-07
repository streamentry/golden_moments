import 'package:golden_moments/features/gentle_activities/models/activity_picture.dart';

/// Where step [step] of the Daily moment on [day] starts in a picture list.
/// The day of the year moves the starting point, so the same moment does not
/// come up every day. Shared with the reminders, which name these pictures.
int dailyMomentOffset(DateTime day, int step) =>
    day.difference(DateTime(day.year)).inDays + step;

/// The pictures the Daily moment shows on [day], in order.
List<ActivityPicture> dailyMomentPictures(
  DateTime day,
  List<ActivityPicture> pictures, {
  int steps = 3,
}) => [
  if (pictures.isNotEmpty)
    for (var step = 0; step < steps; step++)
      pictures[dailyMomentOffset(day, step) % pictures.length],
];
