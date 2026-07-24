/// Calculates the accuracy score of the session.
/// Returns a value between 0 and 100.
double calculateAccuracy({
  required int validReps,
  required int formBreaks,
}) {
  final totalAttempts = validReps + formBreaks;
  if (totalAttempts == 0) return 0.0;
  return (validReps / totalAttempts) * 100.0;
}
