import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_definition.dart';
import 'exercise_tracker.dart';
import '../utils/angle_math.dart';

class HoldTimer extends ExerciseTracker {
  final AngleSmoother _angleSmoother = AngleSmoother(windowSize: 5);

  int _holdSeconds = 0;
  int _formBreaksCount = 0;
  bool _showWarning = false;
  
  DateTime? _lastTick;

  HoldTimer(ExerciseDefinition definition) : super(definition);

  @override
  int get progress => _holdSeconds;

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
    final angle = _extractAngle(pose);
    if (angle == null) return;

    _angleSmoother.add(angle);
    final smoothedAngle = _angleSmoother.smoothedAngle;
    if (smoothedAngle == 0.0) return;

    final minAngle = exerciseDefinition.downThresholdDeg; // e.g. 160
    final maxAngle = exerciseDefinition.upThresholdDeg;   // e.g. 180

    if (smoothedAngle >= minAngle && smoothedAngle <= maxAngle) {
      // Valid hold
      final now = DateTime.now();
      if (_lastTick == null) {
        _lastTick = now;
      } else {
        if (now.difference(_lastTick!).inSeconds >= 1) {
          _holdSeconds++;
          _lastTick = now;
        }
      }
    } else {
      // Broke form
      if (_lastTick != null) {
        _formBreaksCount++;
        _showWarning = true;
        _lastTick = null; // Reset hold until they are back in position
      }
    }
  }

  double? _extractAngle(Pose pose) {
    if (exerciseDefinition.primaryJoint == JointTriplet.shoulderHipAnkle) {
      return _getAngle(
        pose,
        PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
        PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle,
      );
    }
    return null;
  }

  double? _getAngle(
    Pose pose,
    PoseLandmarkType l1, PoseLandmarkType r1,
    PoseLandmarkType l2, PoseLandmarkType r2,
    PoseLandmarkType l3, PoseLandmarkType r3,
  ) {
    final leftConf = (pose.landmarks[l1]?.likelihood ?? 0) +
                     (pose.landmarks[l2]?.likelihood ?? 0) +
                     (pose.landmarks[l3]?.likelihood ?? 0);
                     
    final rightConf = (pose.landmarks[r1]?.likelihood ?? 0) +
                      (pose.landmarks[r2]?.likelihood ?? 0) +
                      (pose.landmarks[r3]?.likelihood ?? 0);

    if (leftConf == 0 && rightConf == 0) return null;

    final side = leftConf > rightConf ? 'left' : 'right';
    
    if (side == 'left') {
      return angleBetweenPoints(
        ax: pose.landmarks[l1]!.x,
        ay: pose.landmarks[l1]!.y,
        bx: pose.landmarks[l2]!.x,
        by: pose.landmarks[l2]!.y,
        cx: pose.landmarks[l3]!.x,
        cy: pose.landmarks[l3]!.y,
      );
    } else {
      return angleBetweenPoints(
        ax: pose.landmarks[r1]!.x,
        ay: pose.landmarks[r1]!.y,
        bx: pose.landmarks[r2]!.x,
        by: pose.landmarks[r2]!.y,
        cx: pose.landmarks[r3]!.x,
        cy: pose.landmarks[r3]!.y,
      );
    }
  }
}
