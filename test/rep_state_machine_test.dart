import 'package:flutter_test/flutter_test.dart';
import 'package:sih/logic/rep_state_machine.dart';
import 'package:sih/models/exercise_definition.dart';
import 'package:sih/data/exercise_catalog.dart';

// Helper to create a minimal Pose with specific landmarks for testing.
// Note: RepStateMachine.processPose uses the full Pose pipeline which
// requires actual PoseLandmarks. These tests verify the state machine
// construction and basic property access; end-to-end rep counting
// requires integration tests with real pose data.
void main() {
  group('RepStateMachine - Construction', () {
    test('Initializes with zero reps and zero form breaks', () {
      final definition = ExerciseCatalog.exercises.firstWhere((e) => e.id == 'pushup');
      final sm = RepStateMachine(definition);

      expect(sm.progress, 0);
      expect(sm.formBreaks, 0);
      expect(sm.showCheaterWarning, false);
    });

    test('Initializes for squat exercise', () {
      final definition = ExerciseCatalog.exercises.firstWhere((e) => e.id == 'squat');
      final sm = RepStateMachine(definition);

      expect(sm.progress, 0);
      expect(sm.formBreaks, 0);
      expect(sm.showCheaterWarning, false);
    });

    test('clearCheaterWarning resets warning flag', () {
      final definition = ExerciseCatalog.exercises.firstWhere((e) => e.id == 'pushup');
      final sm = RepStateMachine(definition);

      // Warning should start false
      expect(sm.showCheaterWarning, false);
      
      // Clearing when already false should be safe
      sm.clearCheaterWarning();
      expect(sm.showCheaterWarning, false);
    });

    test('All catalog exercises can create a RepStateMachine', () {
      for (final exercise in ExerciseCatalog.exercises) {
        if (exercise.mode == TrackingMode.repBased) {
          final sm = RepStateMachine(exercise);
          expect(sm.progress, 0);
          expect(sm.formBreaks, 0);
        }
      }
    });
  });
}
