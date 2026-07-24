import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  final bool isPositionOk;

  const StatusIndicator({Key? key, required this.isPositionOk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isPositionOk ? Colors.greenAccent : Colors.amber;
    final text = isPositionOk ? "Position OK" : "Adjust Camera — Full Body Not Visible";
    final icon = isPositionOk ? Icons.check_circle : Icons.warning_amber_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
