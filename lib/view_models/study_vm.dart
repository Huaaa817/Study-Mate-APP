import 'package:flutter/material.dart';
import 'package:flutter_app/repositories/study_repo.dart';

class StudyViewModel extends ChangeNotifier {
  final StudyRepository _repository;
  final String _userId;

  StudyViewModel(this._repository, this._userId);

  Map<String, int> _dailyLogs = {};
  Map<String, int> get dailyLogs => _dailyLogs;

  /// 上傳本次專注時間（秒）
  Future<void> uploadStudyDuration(int seconds) async {
    if (seconds > 0) {
      await _repository.addStudyDuration(_userId, seconds);
    }
  }

  /// 抓取最近 7 天的每日讀書時間
  Future<void> fetchDailyLogs() async {
    _dailyLogs = await _repository.getDailyStudyLog(_userId);
    notifyListeners();
  }

  int seconds = 0;
  int mood = 0;
  int feed = 0;
  Future<void> fetchDataByDate(String date) async {
    final data = await _repository.fetchLogByDate(_userId, date);
    seconds = data['seconds'] ?? 0;
    mood = data['mood'] ?? 0;
    feed = data['feed'] ?? 0;
    notifyListeners();
  }
}
