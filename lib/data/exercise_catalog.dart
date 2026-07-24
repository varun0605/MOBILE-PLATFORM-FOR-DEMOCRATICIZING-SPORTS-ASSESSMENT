import '../models/exercise_definition.dart';

class ExerciseCatalog {
  static const List<ExerciseDefinition> exercises = [
    ExerciseDefinition(
      id: 'pushup',
      displayName: 'Push-Up',
      iconAsset: 'assets/icons/pushup.png', // Placeholder, we might use icons instead
      mode: TrackingMode.repBased,
      primaryJoint: JointTriplet.shoulderElbowWrist,
      upThresholdDeg: 160.0,
      downThresholdDeg: 90.0,
    ),
    ExerciseDefinition(
      id: 'squat',
      displayName: 'Squat',
      iconAsset: 'assets/icons/squat.png',
      mode: TrackingMode.repBased,
      primaryJoint: JointTriplet.hipKneeAnkle,
      upThresholdDeg: 160.0,
      downThresholdDeg: 100.0,
    ),
    ExerciseDefinition(
      id: 'lunge',
      displayName: 'Lunge',
      iconAsset: 'assets/icons/lunge.png',
      mode: TrackingMode.repBased,
      primaryJoint: JointTriplet.hipKneeAnkle, // Note: front leg logic handled by getting most confident side
      upThresholdDeg: 160.0,
      downThresholdDeg: 100.0,
    ),
    ExerciseDefinition(
      id: 'situp',
      displayName: 'Sit-Up',
      iconAsset: 'assets/icons/situp.png',
      mode: TrackingMode.repBased,
      primaryJoint: JointTriplet.shoulderHipKnee,
      upThresholdDeg: 150.0,
      downThresholdDeg: 70.0,
    ),
    ExerciseDefinition(
      id: 'bicep_curl',
      displayName: 'Bicep Curl',
      iconAsset: 'assets/icons/bicep_curl.png',
      mode: TrackingMode.repBased,
      primaryJoint: JointTriplet.shoulderElbowWrist,
      upThresholdDeg: 160.0,
      downThresholdDeg: 50.0,
    ),
    ExerciseDefinition(
      id: 'shoulder_press',
      displayName: 'Shoulder Press',
      iconAsset: 'assets/icons/shoulder_press.png',
      mode: TrackingMode.repBased,
      primaryJoint: JointTriplet.elbowShoulderHip,
      upThresholdDeg: 90.0, // inverted: "up" is flexed position
      downThresholdDeg: 160.0, // inverted: lock out is down threshold
      isInverted: true,
    ),
    ExerciseDefinition(
      id: 'high_knees',
      displayName: 'High Knees',
      iconAsset: 'assets/icons/high_knees.png',
      mode: TrackingMode.repBased,
      primaryJoint: JointTriplet.highKnees, // specialized joint triplet
      upThresholdDeg: 0.0, // handled by HighKneesTracker
      downThresholdDeg: 0.0, // handled by HighKneesTracker
    ),
    ExerciseDefinition(
      id: 'plank',
      displayName: 'Plank',
      iconAsset: 'assets/icons/plank.png',
      mode: TrackingMode.timeBased,
      primaryJoint: JointTriplet.shoulderHipAnkle,
      upThresholdDeg: 180.0, // Upper limit of valid band
      downThresholdDeg: 160.0, // Lower limit of valid band
    ),
  ];
}
