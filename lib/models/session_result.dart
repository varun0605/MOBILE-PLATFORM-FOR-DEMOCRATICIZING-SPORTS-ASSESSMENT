import 'dart:convert';

class SessionResult {
  final int? id; // For SQLite
  final String exerciseId;
  final int validReps;
  final int formBreaks;
  final double accuracy;
  final int durationSeconds;
  final DateTime timestamp;

  SessionResult({
    this.id,
    required this.exerciseId,
    required this.validReps,
    required this.formBreaks,
    required this.accuracy,
    required this.durationSeconds,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'validReps': validReps,
      'formBreaks': formBreaks,
      'accuracy': accuracy,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SessionResult.fromMap(Map<String, dynamic> map) {
    return SessionResult(
      id: map['id'] as int?,
      exerciseId: map['exerciseId'] ?? map['e'] ?? 'pushup', // fallback for old QR data if 'e' is used
      validReps: map['validReps'] ?? map['r'] ?? 0,
      formBreaks: map['formBreaks'] ?? map['b'] ?? 0,
      accuracy: (map['accuracy'] ?? map['a'] ?? 0).toDouble(),
      durationSeconds: map['durationSeconds'] ?? map['d'] ?? 0,
      timestamp: (map['timestamp'] ?? map['t']) != null 
          ? DateTime.parse(map['timestamp'] ?? map['t']) 
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SessionResult.fromJson(String source) => 
      SessionResult.fromMap(json.decode(source));
}
