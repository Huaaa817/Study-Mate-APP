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

  /// 初始化或 App 啟動時載入狀態（依照 Firestore 讀取今日秒數與聊天加上昨日mood判斷 mood）
  /// 只在 今天沒有資料 時，才用今天秒數來加到昨天的 baseMood，並 不要儲存進 baseMood 中，只儲存在 value 裡：
  // Future<void> updateMood() async {
  //   final status = await _repo.loadMood();
  //   final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  //   final todaySeconds = await _repo.getDailyStudySeconds(userId, today);
  //   final hasChat = await _repo.checkIfUserChattedToday();

  //   final previousBase = status?.baseMood ?? 2;
  //   final additional = _calculateAdditionalFromSeconds(todaySeconds);
  //   final mood = (previousBase + additional + (hasChat ? 1 : 0)).clamp(0, 5);

  //   final newStatus = MoodStatus(
  //     value: mood,
  //     updatedDate: today,
  //     baseMood: previousBase, // 仍保留昨天的基準
  //   );

  //   // 如果今天狀態已存在且 mood 沒有改變，就不寫入 Firestore
  //   if (status?.updatedDate == today && status?.value == mood) {
  //     _mood = mood;
  //     notifyListeners();
  //     return;
  //   }

  //   // 有變化才寫入
  //   await _repo.saveMood(newStatus);
  //   _mood = mood;
  //   notifyListeners();
  // }
  Future<void> updateMood() async {
    final status = await _repo.loadMood();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // ✅ 若今天是新的一天（跨日），則重置 mood 為 2，並更新 baseMood
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

    // ✅ 以下是「今天已經有記錄」的情況，重新計算並動態更新
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


  /// 根據 Firestore 中的「今日總秒數」與聊天狀態，重新計算 mood
  // Future<void> updateMood() async {
  //   final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  //   // 讀取 Firestore 中的今日總秒數
  //   final todayStudyLogs = await _studyRepo.getDailyStudyLog(userId);
  //   final totalSeconds = todayStudyLogs[today] ?? 0;

  //   // 根據總秒數 + 有無聊天，重新計算 mood
  //   final hasChat = await _repo.checkIfUserChattedToday();
  //   debugPrint('updateMood - hasChat: $hasChat');

  //   final baseMood = _calculateAdditionalFromSeconds(totalSeconds, _latestStatus.baseMood);
  //   final mood = (baseMood + (hasChat ? 1 : 0)).clamp(0, 5);

  //   final newStatus = MoodStatus(
  //     value: mood,
  //     updatedDate: today,
  //     baseMood: baseMood,
  //   );
  //   // 印出 newStatus 內容
  //   // debugPrint('updateMood - newStatus.value: ${newStatus.value}, updatedDate: ${newStatus.updatedDate}, baseMood: ${newStatus.baseMood}');

  //   await _repo.saveMood(newStatus);
  //   _mood = mood;
  //   notifyListeners();
  // }

  // 心情條邏輯：每滿 10 秒加一格，最多加2格
  int _calculateAdditionalFromSeconds(int seconds) {
    final additional = (seconds ~/ 10).clamp(0, 2); // 最多 +2
    debugPrint('_calculateAdditionalFromSeconds - seconds: $seconds, additional: $additional');
    return additional;
  }

}
