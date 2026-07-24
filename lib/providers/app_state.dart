import 'package:flutter/foundation.dart';
import '../data/session_repository.dart';
import '../models/session_result.dart';

class AppState extends ChangeNotifier {
  final SessionRepository _repository = SessionRepository();
  List<SessionResult> _sessions = [];
  bool _isLoading = false;

  List<SessionResult> get sessions => _sessions;
  bool get isLoading => _isLoading;

  int get totalReps => _sessions.fold(0, (sum, s) => sum + s.validReps);
  int get totalSessions => _sessions.length;

  int get currentStreak {
    if (_sessions.isEmpty) return 0;
    
    // Sort sessions descending by date
    final sorted = List<SessionResult>.from(_sessions)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (var session in sorted) {
      final date = DateTime(session.timestamp.year, session.timestamp.month, session.timestamp.day);
      if (lastDate == null) {
        lastDate = date;
        streak = 1;
      } else {
        final diff = lastDate.difference(date).inDays;
        if (diff == 1) {
          streak++;
          lastDate = date;
        } else if (diff > 1) {
          break; // streak broken
        }
      }
    }
    
    // Check if the streak is active today or yesterday
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (lastDate != null && todayDate.difference(lastDate).inDays > 1) {
      return 0; // Streak was broken
    }
    
    return streak;
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();
    
    _sessions = await _repository.getAllSessions();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSession(SessionResult session) async {
    await _repository.insertSession(session);
    await loadSessions(); // reload to get the new session
  }
}
