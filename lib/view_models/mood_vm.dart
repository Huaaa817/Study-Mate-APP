import 'package:flutter/material.dart';
import 'package:flutter_app/models/mood_status.dart';
import 'package:flutter_app/repositories/mood_repo.dart';
import 'package:intl/intl.dart';

class MoodViewModel extends ChangeNotifier {
  final String userId;
  MoodViewModel(this.userId);

  final MoodRepository _repo = MoodRepository();

  int _mood = 2;

  int get mood => _mood;

  Future<void> updateMood() async {
    final status = await _repo.loadMood();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 若今天是新的一天（跨日），則重置 mood 為 2，並更新 baseMood
    if (status == null || status.updatedDate != today) {
      final newStatus = MoodStatus(
        value: 2,
        updatedDate: today,
        baseMood: 2,
      );
      await _repo.saveMood(newStatus);
      await _repo.saveDailyMood(userId, today, 2);
      _mood = 2;
      notifyListeners();
      return;
    }

    // 以下是「今天已經有記錄」的情況，重新計算並動態更新
    final todaySeconds = await _repo.getDailyStudySeconds(userId, today);
    final hasChat = await _repo.checkIfUserChattedToday();
    debugPrint('updateMood - hasChat: $hasChat');

    final previousBase = status.baseMood;
    final additional = _calculateAdditionalFromSeconds(todaySeconds);
    final mood = (previousBase + additional + (hasChat ? 1 : 0)).clamp(0, 5);

    final newStatus = MoodStatus(
      value: mood,
      updatedDate: today,
      baseMood: previousBase,
    );

    if (status.value == mood) {
      _mood = mood;
      notifyListeners();
      return;
    }

    await _repo.saveMood(newStatus);
    await _repo.saveDailyMood(userId, today, mood);
    _mood = mood;
    notifyListeners();
  }

  // 心情條邏輯：每滿 10 秒加一格，最多加2格
  int _calculateAdditionalFromSeconds(int seconds) {
    final additional = (seconds ~/ 10).clamp(0, 2); // 最多 +2
    debugPrint('_calculateAdditionalFromSeconds - seconds: $seconds, additional: $additional');
    return additional;
  }

}
