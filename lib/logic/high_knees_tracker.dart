import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_definition.dart';
import 'exercise_tracker.dart';

class HighKneesTracker extends ExerciseTracker {
  int _validReps = 0;
  int _formBreaksCount = 0;
  bool _showWarning = false;

  bool _leftIsUp = false;
  bool _rightIsUp = false;

  String? _lastLeg;

  HighKneesTracker(ExerciseDefinition definition) : super(definition);

  @override
  int get progress => _validReps;

  @override
  int get formBreaks => _formBreaksCount;

  @override
  bool get showCheaterWarning => _showWarning;

  @override
  void clearCheaterWarning() {
    _showWarning = false;
  }

  @override
  void processPose(Pose pose) {
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    if (leftHip == null || leftKnee == null || rightHip == null || rightKnee == null) return;
    if (leftHip.likelihood < 0.5 || leftKnee.likelihood < 0.5 || rightHip.likelihood < 0.5 || rightKnee.likelihood < 0.5) return;

    // Y axis increases downwards.
    // Up threshold: knee goes above (or very close to) the hip.
    final leftUp = leftKnee.y < leftHip.y + 20.0;
    final leftDown = leftKnee.y > leftHip.y + 60.0;

    final rightUp = rightKnee.y < rightHip.y + 20.0;
    final rightDown = rightKnee.y > rightHip.y + 60.0;

    // Handle Left Leg
    if (leftUp && !_leftIsUp) {
      _leftIsUp = true;
      if (_lastLeg != 'left') {
        _validReps++;
        _lastLeg = 'left';
      } else {
        // They didn't alternate!
        _formBreaksCount++;
        _showWarning = true;
      }
    } else if (leftDown && _leftIsUp) {
      _leftIsUp = false;
    }

    // Handle Right Leg
    if (rightUp && !_rightIsUp) {
      _rightIsUp = true;
      if (_lastLeg != 'right') {
        _validReps++;
        _lastLeg = 'right';
      } else {
        // They didn't alternate!
        _formBreaksCount++;
        _showWarning = true;
      }
    } else if (rightDown && _rightIsUp) {
      _rightIsUp = false;
    }
  }
}
