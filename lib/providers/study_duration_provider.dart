import 'package:flutter/material.dart';

class StudyDurationProvider extends ChangeNotifier {
  int _duration = 10;

  int get duration => _duration;

  void setDuration(int seconds) {
    _duration = seconds;
    notifyListeners();
  }
}
