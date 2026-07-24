import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectionService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );
  bool _canProcess = true;
  bool _isBusy = false;

  Future<List<Pose>> processImage(InputImage inputImage) async {
    if (!_canProcess) return [];
    if (_isBusy) return [];
    _isBusy = true;
    
    try {
      final poses = await _poseDetector.processImage(inputImage);
      return poses;
    } finally {
      _isBusy = false;
    }
  }

  void dispose() {
    _canProcess = false;
    _poseDetector.close();
  }
}
