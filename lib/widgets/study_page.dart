import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 從路由參數獲取 duration，預設 10 秒
    final duration = int.tryParse(GoRouterState.of(context).uri.queryParameters['duration'] ?? '10') ?? 10;
    _remainingSeconds = duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        GoRouter.of(context).go('/feed');
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('學習')),
      body: Center(
        child: Text(
          '剩餘時間：$_remainingSeconds 秒',
          style: const TextStyle(fontSize: 24),
        ),
      ),
      // 無底部導航欄
    );
  }
}