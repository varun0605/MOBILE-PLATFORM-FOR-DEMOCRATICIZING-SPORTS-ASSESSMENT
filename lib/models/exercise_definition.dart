enum TrackingMode {
  repBased,
  timeBased,
}

enum JointTriplet {
  shoulderElbowWrist,
  hipKneeAnkle,
  shoulderHipKnee,
  shoulderHipAnkle,
  elbowShoulderHip,
  highKnees, // Special case for high knees
}

class ExerciseDefinition {
  final String id;                  // 'pushup','squat','lunge','situp','plank', etc.
  final String displayName;
  final String iconAsset;           // e.g. 'assets/icons/pushup.png' or similar
  final TrackingMode mode;          // repBased or timeBased
  final JointTriplet primaryJoint;
  final double upThresholdDeg;
  final double downThresholdDeg;
  final bool useSecondaryJointCheck;
  final bool isInverted;            // For exercises like Shoulder Press where "up" is flexed (<90) and "rep" is extension (>160)

  const ExerciseDefinition({
    required this.id,
    required this.displayName,
    required this.iconAsset,
    required this.mode,
    required this.primaryJoint,
    required this.upThresholdDeg,
    required this.downThresholdDeg,
    this.useSecondaryJointCheck = false,
    this.isInverted = false,
  });
}
