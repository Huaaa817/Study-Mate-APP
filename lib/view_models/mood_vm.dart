import 'package:flutter/material.dart';
import 'package:flutter_app/models/mood_status.dart';
import 'package:flutter_app/repositories/mood_repo.dart';
import 'package:flutter_app/repositories/study_repo.dart';
import 'package:intl/intl.dart';

class MoodViewModel extends ChangeNotifier {
  final String userId;
  MoodViewModel(this.userId);

  final MoodRepository _repo = MoodRepository();
  final StudyRepository _studyRepo = StudyRepository();

  int _mood = 2;
  late MoodStatus _latestStatus;

  int get mood => _mood;

  /// 初始化或 App 啟動時載入狀態（依照 Firestore 讀取今日秒數與聊天判斷 mood）
  Future<void> loadMood() async {
    final status = await _repo.loadMood();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 讀取今日專注秒數與是否有聊天
    final todayStudyLogs = await _studyRepo.getDailyStudyLog(userId);
    final todaySeconds = todayStudyLogs[today] ?? 0;
    final hasChat = await _repo.checkIfUserChattedToday();

    int baseMood;

    if (status != null) {
      if (status.updatedDate == today) {
        _mood = status.value;
        _latestStatus = status;
        notifyListeners();
        return;
      } else {
        // 用昨天的 baseMood 當作今天的起點
        baseMood = _calculateMoodFromSeconds(todaySeconds, status.baseMood);
      }
    } else {
      baseMood = _calculateMoodFromSeconds(todaySeconds, 2); // 初始 mood = 2
    }

    int mood = (baseMood + (hasChat ? 1 : 0)).clamp(0, 5);

    final newStatus = MoodStatus(
      value: mood,
      updatedDate: today,
      baseMood: baseMood,
    );

    await _repo.saveMood(newStatus);
    _mood = mood;
    _latestStatus = newStatus;
    notifyListeners();
  }

  /// 根據 Firestore 中的「今日總秒數」與聊天狀態，重新計算 mood
  Future<void> updateMood() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 讀取 Firestore 中的今日總秒數
    final todayStudyLogs = await _studyRepo.getDailyStudyLog(userId);
    final totalSeconds = todayStudyLogs[today] ?? 0;

    // 根據總秒數 + 有無聊天，重新計算 mood
    final hasChat = await _repo.checkIfUserChattedToday();

    final baseMood = _calculateMoodFromSeconds(totalSeconds, _latestStatus.baseMood);
    final mood = (baseMood + (hasChat ? 1 : 0)).clamp(0, 5);

    final newStatus = MoodStatus(
      value: mood,
      updatedDate: today,
      baseMood: baseMood,
    );

    await _repo.saveMood(newStatus);
    _mood = mood;
    _latestStatus = newStatus;
    notifyListeners();
  }

  /// 心情條邏輯：每滿 30 分鐘（1800 秒）加一格，最多加到 3 格
  int _calculateMoodFromSeconds(int seconds, int base) {
    final additional = (seconds~/30).clamp(0, 3); // 最多 +3
    return (base + additional).clamp(0, 4);
  }
}
