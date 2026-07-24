import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';

import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/exercise_definition.dart';
import '../models/session_result.dart';
import '../services/pose_detection_service.dart';
import '../logic/exercise_tracker.dart';
import '../logic/rep_state_machine.dart';
import '../logic/hold_timer.dart';
import '../logic/high_knees_tracker.dart';
import '../utils/accuracy_score.dart';
import '../widgets/camera_feed.dart';
import '../widgets/pose_painter.dart';
import '../widgets/rep_counter_display.dart';
import '../widgets/cheater_flash_overlay.dart';
import '../widgets/status_indicator.dart';
import 'passport_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final ExerciseDefinition exerciseDefinition;

  const AssessmentScreen({Key? key, required this.exerciseDefinition}) : super(key: key);

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final PoseDetectionService _poseDetectionService = PoseDetectionService();
  late ExerciseTracker _exerciseTracker;

  CustomPaint? _customPaint;
  bool _isPositionOk = false;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });

    if (widget.exerciseDefinition.id == 'high_knees') {
      _exerciseTracker = HighKneesTracker(widget.exerciseDefinition);
    } else if (widget.exerciseDefinition.mode == TrackingMode.repBased) {
      _exerciseTracker = RepStateMachine(widget.exerciseDefinition);
    } else {
      _exerciseTracker = HoldTimer(widget.exerciseDefinition);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    try {
      _poseDetectionService.dispose();
    } catch (e) {
      // Ignore MissingPluginException on web
      debugPrint('Pose detector disposal error (expected on web): $e');
    }
    super.dispose();
  }

  void _processImage(InputImage inputImage) async {
    try {
      final poses = await _poseDetectionService.processImage(inputImage);
      if (poses.isEmpty || !mounted) return;

      final pose = poses.first;
      
      _checkPositionOk(pose);

      if (_isPositionOk) {
        bool hadWarning = _exerciseTracker.showCheaterWarning;
        _exerciseTracker.processPose(pose);
        if (!hadWarning && _exerciseTracker.showCheaterWarning) {
          HapticFeedback.mediumImpact();
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                _exerciseTracker.clearCheaterWarning();
              });
            }
          });
        }
      }

      if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
        final painter = PosePainter(
          poses,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          CameraLensDirection.front,
        );
        if (mounted) {
          setState(() {
            _customPaint = CustomPaint(painter: painter);
          });
        }
      }
    } catch (e) {
      // Handle MissingPluginException on web and other errors gracefully
      debugPrint('Pose processing error: $e');
    }
  }

  void _checkPositionOk(Pose pose) {
    bool ok = false;
    final joint = widget.exerciseDefinition.primaryJoint;
    
    if (joint == JointTriplet.shoulderElbowWrist) {
      ok = _checkConfidence(pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist) ||
           _checkConfidence(pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
    } else if (joint == JointTriplet.hipKneeAnkle) {
      ok = _checkConfidence(pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle) ||
           _checkConfidence(pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    } else if (joint == JointTriplet.shoulderHipKnee) {
      ok = _checkConfidence(pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee) ||
           _checkConfidence(pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    } else if (joint == JointTriplet.shoulderHipAnkle) {
      ok = _checkConfidence(pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftAnkle) ||
           _checkConfidence(pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, PoseLandmarkType.rightAnkle);
    } else if (joint == JointTriplet.elbowShoulderHip) {
      ok = _checkConfidence(pose, PoseLandmarkType.leftElbow, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip) ||
           _checkConfidence(pose, PoseLandmarkType.rightElbow, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    } else if (joint == JointTriplet.highKnees) {
      // High knees require both legs to be tracked reliably
      ok = _checkConfidence(pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.rightHip) &&
           _checkConfidence(pose, PoseLandmarkType.rightKnee, PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle);
    }

    if (_isPositionOk != ok) {
      setState(() {
        _isPositionOk = ok;
      });
    }
  }
  
  bool _checkConfidence(Pose pose, PoseLandmarkType l1, PoseLandmarkType l2, PoseLandmarkType l3) {
    return (pose.landmarks[l1]?.likelihood ?? 0) > 0.6 &&
           (pose.landmarks[l2]?.likelihood ?? 0) > 0.6 &&
           (pose.landmarks[l3]?.likelihood ?? 0) > 0.6;
  }

  void _endAssessment() {
    _timer?.cancel();

    final result = SessionResult(
      exerciseId: widget.exerciseDefinition.id,
      validReps: _exerciseTracker.progress,
      formBreaks: _exerciseTracker.formBreaks,
      accuracy: calculateAccuracy(validReps: _exerciseTracker.progress, formBreaks: _exerciseTracker.formBreaks),
      durationSeconds: _elapsedSeconds,
      timestamp: DateTime.now(),
    );

    // Save session — wrap in try-catch for web safety
    try {
      Provider.of<AppState>(context, listen: false).addSession(result);
    } catch (e) {
      debugPrint('Failed to save session: $e');
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            PassportScreen(result: result),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false, // Remove all previous routes
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String warningMessage = widget.exerciseDefinition.mode == TrackingMode.timeBased ? "HOLD STRAIGHT!" : "GO LOWER!";
    
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera feed or placeholder on web
          if (!kIsWeb)
            CameraFeed(
              onImage: _processImage,
              customPaint: _customPaint,
            )
          else
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, size: 80, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      "Camera not available on web",
                      style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Use a mobile device for live tracking",
                      style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer, size: 18, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              _formatDuration(_elapsedSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusIndicator(isPositionOk: _isPositionOk),
                    ],
                  ),
                ),
                
                // Rep counter
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 32.0),
                    child: RepCounterDisplay(count: _exerciseTracker.progress),
                  ),
                ),
                
                // End button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [Colors.redAccent.shade400, Colors.red.shade700],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _endAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "END ASSESSMENT",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          CheaterFlashOverlay(
            isVisible: _exerciseTracker.showCheaterWarning,
            message: warningMessage,
          ),
        ],
      ),
    );
  }
}
