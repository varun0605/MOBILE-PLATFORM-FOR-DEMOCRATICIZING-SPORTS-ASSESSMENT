import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/exercise_definition.dart';
import '../data/exercise_catalog.dart';
import 'assessment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ExerciseDefinition _selectedExercise = ExerciseCatalog.exercises.first; // pushup
  bool _isLoading = false;

  Future<void> _startAssessment() async {
    setState(() => _isLoading = true);
    final status = await Permission.camera.request();
    setState(() => _isLoading = false);

    if (status.isGranted) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              AssessmentScreen(exerciseDefinition: _selectedExercise),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Camera permission is required for AI tracking"),
          action: SnackBarAction(
            label: "Settings",
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Text(
                "SPORTS TALENT\nASSESSMENT",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              Text(
                "AI-Powered Mobile Platform",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              const Text(
                "SELECT EXERCISE",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildExerciseCard(
                      title: "PUSH-UP",
                      icon: Icons.fitness_center,
                      exercise: ExerciseCatalog.exercises.firstWhere((e) => e.id == 'pushup'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildExerciseCard(
                      title: "SQUAT",
                      icon: Icons.directions_run,
                      exercise: ExerciseCatalog.exercises.firstWhere((e) => e.id == 'squat'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _startAssessment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      "START ASSESSMENT",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard({
    required String title,
    required IconData icon,
    required ExerciseDefinition exercise,
  }) {
    final isSelected = _selectedExercise.id == exercise.id;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedExercise = exercise),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondary.withOpacity(0.1) : const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.secondary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? colorScheme.secondary : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? colorScheme.secondary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
