import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_definition.dart';

abstract class ExerciseTracker {
  final ExerciseDefinition exerciseDefinition;
  
  ExerciseTracker(this.exerciseDefinition);

  /// Process the current pose. This might compute angles and update state.
  void processPose(Pose pose);
  
  /// Returns the current number of valid reps or valid held seconds.
  int get progress;

  /// Returns the current number of form breaks.
  int get formBreaks;

  /// Returns whether a cheater warning should currently be shown.
  bool get showCheaterWarning;
  
  /// Clears the cheater warning state.
  void clearCheaterWarning();
}
