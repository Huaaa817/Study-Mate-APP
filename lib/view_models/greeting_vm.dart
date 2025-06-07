import 'package:flutter/material.dart';
import '/repositories/greeting_repo.dart';

class GreetingViewModel extends ChangeNotifier {
  final GreetingRepository _repo = GreetingRepository();

  String? _greeting;
  bool _isLoading = false;

  String? get greeting => _greeting;
  bool get isLoading => _isLoading;

  Future<void> loadGreeting() async {
    _isLoading = true;
    notifyListeners();

    try {
      _greeting = await _repo.generateGreeting();
    } catch (e) {
      _greeting = '取得問候語失敗';
      print('Error loading greeting: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
