import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/exercise_definition.dart';
import 'exercise_tracker.dart';
import '../utils/angle_math.dart';

enum RepState {
  up,
  goingDown,
  down,
  goingUp,
}

class RepStateMachine extends ExerciseTracker {
  RepState _currentState = RepState.up;
  final AngleSmoother _angleSmoother = AngleSmoother(windowSize: 5);

  double _extremeAngleThisRep = 180.0;
  
  int _validReps = 0;
  int _formBreaksCount = 0;
  bool _showWarning = false;

  RepStateMachine(ExerciseDefinition definition) : super(definition) {
    if (definition.isInverted) {
      _extremeAngleThisRep = 0.0;
    }
  }

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
    final angle = _extractAngle(pose);
    if (angle == null) return;

    _angleSmoother.add(angle);
    final smoothedAngle = _angleSmoother.smoothedAngle;
    if (smoothedAngle == 0.0) return; // not enough data or invalid

    final isInverted = exerciseDefinition.isInverted;

    if (isInverted) {
      if (smoothedAngle > _extremeAngleThisRep) {
        _extremeAngleThisRep = smoothedAngle;
      }
    } else {
      if (smoothedAngle < _extremeAngleThisRep) {
        _extremeAngleThisRep = smoothedAngle;
      }
    }

    final upThreshold = exerciseDefinition.upThresholdDeg;
    final downThreshold = exerciseDefinition.downThresholdDeg;

    switch (_currentState) {
      case RepState.up:
        if (isInverted ? (smoothedAngle > upThreshold + 10.0) : (smoothedAngle < upThreshold - 10.0)) {
          _currentState = RepState.goingDown;
          _extremeAngleThisRep = smoothedAngle;
        }
        break;

      case RepState.goingDown:
        if (isInverted ? (smoothedAngle > downThreshold) : (smoothedAngle < downThreshold)) {
          _currentState = RepState.down;
        } 
        else if (isInverted ? (smoothedAngle < _extremeAngleThisRep - 15.0) : (smoothedAngle > _extremeAngleThisRep + 15.0)) {
          _formBreaksCount++;
          _showWarning = true;
          _currentState = RepState.goingUp;
        }
        break;

      case RepState.down:
        if (isInverted ? (smoothedAngle < downThreshold - 10.0) : (smoothedAngle > downThreshold + 10.0)) {
          _currentState = RepState.goingUp;
        }
        break;

      case RepState.goingUp:
        if (isInverted ? (smoothedAngle < upThreshold) : (smoothedAngle > upThreshold)) {
          _currentState = RepState.up;
          _validReps++;
        }
        break;
    }
  }

  double? _extractAngle(Pose pose) {
    if (exerciseDefinition.primaryJoint == JointTriplet.shoulderElbowWrist) {
      return _getAngle(
        pose,
        PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftElbow, PoseLandmarkType.rightElbow,
        PoseLandmarkType.leftWrist, PoseLandmarkType.rightWrist,
      );
    } else if (exerciseDefinition.primaryJoint == JointTriplet.hipKneeAnkle) {
      return _getAngle(
        pose,
        PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
        PoseLandmarkType.leftKnee, PoseLandmarkType.rightKnee,
        PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle,
      );
    } else if (exerciseDefinition.primaryJoint == JointTriplet.shoulderHipKnee) {
      return _getAngle(
        pose,
        PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
        PoseLandmarkType.leftKnee, PoseLandmarkType.rightKnee,
      );
    } else if (exerciseDefinition.primaryJoint == JointTriplet.elbowShoulderHip) {
      return _getAngle(
        pose,
        PoseLandmarkType.leftElbow, PoseLandmarkType.rightElbow,
        PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftHip, PoseLandmarkType.rightHip,
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
