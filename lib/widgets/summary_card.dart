import 'package:flutter/material.dart';
import '../models/session_result.dart';
import 'qr_passport.dart';

class SummaryCard extends StatelessWidget {
  final SessionResult result;

  const SummaryCard({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A22) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(isDark ? 0.4 : 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withOpacity(isDark ? 0.15 : 0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
            ).createShader(bounds),
            child: Text(
              "TALENT PASSPORT",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBlock(context, "EXERCISE", result.exerciseId.toUpperCase()),
              _buildStatBlock(context, "SCORE", "${result.validReps}"),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBlock(context, "ACCURACY", "${result.accuracy.toStringAsFixed(1)}%"),
              _buildStatBlock(context, "FORM BREAKS", "${result.formBreaks}"),
            ],
          ),
          const SizedBox(height: 32),
          QrPassport(data: result.toJson()),
          const SizedBox(height: 16),
          Text(
            "Scan to verify official score",
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBlock(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
