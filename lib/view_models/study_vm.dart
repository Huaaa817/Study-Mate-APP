import 'package:flutter/material.dart';
import 'package:flutter_app/repositories/study_repo.dart';

class StudyViewModel extends ChangeNotifier {
  final StudyRepository _repository;
  final String _userId;

  StudyViewModel(this._repository, this._userId);

  // 用來存儲最近 7 天的讀書資料
  Map<String, int> _weeklyLogs = {};
  Map<String, int> get weeklyLogs => _weeklyLogs;

  // 用來存儲某一天的具體資料
  int seconds = 0;
  int mood = 0;
  int feed = 0;

  // 上傳本次專注時間（秒）
  Future<void> uploadStudyDuration(int seconds) async {
    if (seconds > 0) {
      await _repository.addStudyDuration(_userId, seconds);
    }
  }

  // 抓取最近 7 天的讀書紀錄
  Future<void> fetchWeeklyLogs() async {
    // 使用 repository 取得最近 7 天的資料
    _weeklyLogs = await _repository.getDailyStudyLog(_userId);
    notifyListeners();
  }

  // 抓取某一天的具體資料
  Future<void> fetchDataByDate(String date) async {
    final data = await _repository.fetchLogByDate(_userId, date);
    seconds = data['seconds'] ?? 0;
    mood = data['mood'] ?? 0;
    feed = data['feed'] ?? 0;
    notifyListeners();
  }
}
