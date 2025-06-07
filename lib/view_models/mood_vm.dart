import 'package:flutter/material.dart';
import 'package:flutter_app/models/mood_status.dart';
import 'package:flutter_app/repositories/mood_repo.dart';
import 'package:intl/intl.dart';

class MoodViewModel extends ChangeNotifier {
  final String userId;
  MoodViewModel(this.userId);

  final MoodRepository _repo = MoodRepository();
  int _mood = 2;
  late MoodStatus _latestStatus;

  int get mood => _mood;

  /// 初始化或 App 啟動時載入狀態
  Future<void> loadMood() async {
    final status = await _repo.loadMood();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (status != null) {
      if (status.updatedDate == today) {
        _mood = status.value;
        _latestStatus = status;
      } else {
        // 日期不同，自動重置，但用昨日心情作為 base
        _mood = status.baseMood;
        _latestStatus = MoodStatus(
          value: _mood,
          updatedDate: today,
          baseMood: _mood,
        );
        await _repo.saveMood(_latestStatus);
      }
      notifyListeners();
    }
  }

  /// 調用此方法於讀書結束時更新 mood（讀書不足 20 秒會扣分）
  Future<void> updateMood({required Duration focusDuration}) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    int baseMood = _latestStatus.baseMood;

    // 根據讀書時數計算
    if (focusDuration.inSeconds >= 20) {
      baseMood = (baseMood + 1).clamp(0, 4);
    } else {
      baseMood = (baseMood - 1).clamp(0, 4);
    }

    // 判斷今天是否有聊天
    final hasChat = await _repo.checkIfUserChattedToday();
    int bonus = hasChat ? 1 : 0;

    _mood = (baseMood + bonus).clamp(0, 4);

    final status = MoodStatus(
      value: _mood,
      updatedDate: today,
      baseMood: baseMood,
    );

    await _repo.saveMood(status);
    _latestStatus = status;
    notifyListeners();
  }

  /// 在首頁自動檢查是否需根據聊天更新心情條（未讀書但有聊天）
  Future<void> autoUpdateMoodIfNeeded() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final status = await _repo.loadMood();
    if (status == null || status.updatedDate == today) return;

    final hasChat = await _repo.checkIfUserChattedToday();
    int baseMood = status.baseMood;
    int mood = baseMood;

    if (hasChat) {
      mood = (baseMood + 1).clamp(0, 4);
    }

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
}
