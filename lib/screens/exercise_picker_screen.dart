import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/exercise_catalog.dart';
import '../models/exercise_definition.dart';
import 'assessment_screen.dart';

class ExercisePickerScreen extends StatefulWidget {
  const ExercisePickerScreen({Key? key}) : super(key: key);

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  ExerciseDefinition _selectedExercise = ExerciseCatalog.exercises.first;
  bool _isLoading = false;

  Future<void> _startAssessment() async {
    setState(() => _isLoading = true);
    final status = await Permission.camera.request();
    setState(() => _isLoading = false);

    if (status.isGranted) {
      if (!mounted) return;
      Navigator.of(context).push(
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

  IconData _getIcon(String id) {
    switch (id) {
      case 'pushup': return Icons.fitness_center;
      case 'squat': return Icons.directions_run;
      case 'lunge': return Icons.nordic_walking;
      case 'situp': return Icons.airline_seat_recline_normal;
      case 'plank': return Icons.horizontal_rule;
      default: return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "SELECT EXERCISE",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1,
                  ),
                  itemCount: ExerciseCatalog.exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = ExerciseCatalog.exercises[index];
                    return _ExerciseCard(
                      exercise: exercise,
                      icon: _getIcon(exercise.id),
                      isSelected: _selectedExercise.id == exercise.id,
                      onTap: () => setState(() => _selectedExercise = exercise),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startAssessment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "START ASSESSMENT",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
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
}

// ─── Animated Exercise Card ──────────────────────────────────
class _ExerciseCard extends StatefulWidget {
  final ExerciseDefinition exercise;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? (isDark ? colorScheme.secondary.withOpacity(0.12) : colorScheme.secondary.withOpacity(0.08))
                : (isDark ? const Color(0xFF1A1A22) : Colors.white),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected
                  ? colorScheme.secondary
                  : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06)),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? colorScheme.secondary.withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: Icon(
                  widget.icon,
                  size: 36,
                  color: widget.isSelected
                      ? colorScheme.secondary
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.exercise.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: widget.isSelected
                      ? colorScheme.secondary
                      : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                ),
              ),
              if (widget.exercise.mode == TrackingMode.timeBased) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8E53).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "HOLD",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8E53),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
