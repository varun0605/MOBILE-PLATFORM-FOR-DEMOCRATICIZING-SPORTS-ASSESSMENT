import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'exercise_picker_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, state, child) {
          return CustomScrollView(
            slivers: [
              // Hero Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 24,
                    left: 24,
                    right: 24,
                    bottom: 32,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              colorScheme.primary.withOpacity(0.15),
                              colorScheme.secondary.withOpacity(0.05),
                              Colors.transparent,
                            ]
                          : [
                              colorScheme.primary.withOpacity(0.08),
                              colorScheme.secondary.withOpacity(0.03),
                              Colors.transparent,
                            ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TALENT",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ).createShader(bounds),
                        child: Text(
                          "Dashboard",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "AI-Powered Sports Assessment",
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stat Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: _GlassStatCard(
                        title: 'TOTAL REPS',
                        value: '${state.totalReps}',
                        icon: Icons.repeat_rounded,
                        gradient: [colorScheme.primary, colorScheme.primary.withOpacity(0.6)],
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _GlassStatCard(
                        title: 'SESSIONS',
                        value: '${state.totalSessions}',
                        icon: Icons.bolt_rounded,
                        gradient: [colorScheme.secondary, colorScheme.secondary.withOpacity(0.6)],
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _GlassStatCard(
                        title: 'STREAK',
                        value: '${state.currentStreak}',
                        icon: Icons.local_fire_department_rounded,
                        gradient: [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
                      )),
                    ],
                  ),
                ),
              ),

              // Start Assessment Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: _AnimatedStartButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const ExercisePickerScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Recent Sessions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                  child: Text(
                    "RECENT SESSIONS",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),

              // Recent Sessions List
              if (state.sessions.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 56,
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No sessions yet",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Start an assessment to see your results",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = state.sessions[index];
                      return _SessionListItem(session: session, isDark: isDark);
                    },
                    childCount: state.sessions.length > 5 ? 5 : state.sessions.length,
                  ),
                ),

              // Bottom padding for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

// ─── Glass Stat Card ─────────────────────────────────────────
class _GlassStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _GlassStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.7),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(isDark ? 0.15 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(colors: gradient).createShader(bounds),
                child: Icon(icon, size: 22, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(colors: gradient).createShader(bounds),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animated Start Button ───────────────────────────────────
class _AnimatedStartButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedStartButton({required this.onPressed});

  @override
  State<_AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<_AnimatedStartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3 + _controller.value * 0.15),
                    blurRadius: 20 + _controller.value * 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.black, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "START ASSESSMENT",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Session List Item ───────────────────────────────────────
class _SessionListItem extends StatelessWidget {
  final dynamic session;
  final bool isDark;

  const _SessionListItem({required this.session, required this.isDark});

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
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary.withOpacity(0.2), colorScheme.secondary.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIcon(session.exerciseId), size: 22, color: colorScheme.primary),
        ),
        title: Text(
          session.exerciseId.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.5),
        ),
        subtitle: Text(
          "Score: ${session.validReps} • Accuracy: ${session.accuracy.toStringAsFixed(1)}%",
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        trailing: Text(
          "${session.timestamp.day}/${session.timestamp.month}",
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
