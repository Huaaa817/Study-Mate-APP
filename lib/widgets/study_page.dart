import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/view_models/me_wm.dart';
import '/providers/background_provider.dart';
import 'package:flutter_app/view_models/study_vm.dart';
import 'package:flutter_app/widgets/rounded_rect_button.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with WidgetsBindingObserver {
  late int _durationInterval;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _durationInterval =
          int.tryParse(
            GoRouterState.of(context).uri.queryParameters['duration'] ?? '60',
          ) ?? 60;

      _startTimer();

      final bgVM = Provider.of<BackgroundViewModel>(context, listen: false);
      if (bgVM.imageUrl != null && bgVM.imageUrl!.isNotEmpty) {
        precacheImage(NetworkImage(bgVM.imageUrl!), context)
            .then((_) {
              print('[LOG] StudyPage: 預先快取圖片完成 ✅');
            })
            .catchError((e) {
              print('[LOG] StudyPage: 預快取圖片失敗 ❌ $e');
            });
      }
      _initialized = true;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _elapsedSeconds++;
      });

      if (_elapsedSeconds % _durationInterval == 0 && _elapsedSeconds != 0) {
        _timer?.cancel();
        _timer = null;

        GoRouter.of(context).push('/feed?duration=$_durationInterval').then((_) {
          if (mounted) _startTimer();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    Provider.of<StudyViewModel>(context, listen: false).uploadStudyDuration(_elapsedSeconds);
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bgVM = Provider.of<BackgroundViewModel>(context);
    final scheme = Theme.of(context).colorScheme;

    final meVM = Provider.of<MeViewModel>(context);
    final userImageUrl = meVM.userImageUrl;

    return Scaffold(
      body: Stack(
        children: [
          if (bgVM.backgroundWidget != null) bgVM.backgroundWidget!,

          // 顯示圖片，保持原位置
          if (userImageUrl != null && userImageUrl.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topLeft,
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Transform.scale(
                      scale: 2.0,
                      alignment: Alignment.topLeft,
                      child: Image.network(
                        userImageUrl,
                        width: 400,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // 調整圓形背景大小與位置，並與倒數時間往上調整
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1, // 圓形位置更往上
            left: 0,
            right: 0,
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -60), // 整體圓形及時間文字稍微往上移
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 調整圓形背景大小
                    Container(
                      width: 350,  // 圓形變小
                      height: 350,  // 圓形變小
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),

                    // 顯示倒數時間
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),

                    // 專注時間文字顯示
                    Positioned(
                      top: 70,
                      child: Text(
                        '專注時間',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.95),
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 調整「結束專注」按鈕位置
          Positioned(
            top: MediaQuery.of(context).size.height * 0.48,  // 使用 top 並將其設為畫面高度的 55% 來調整位置
            left: 0,
            right: 0,
            child: Center(
              child: RoundedRectButton(
                text: '結束專注',
                onPressed: () async {
                  //if (!mounted) return; // 確保頁面仍然存在
                   debugPrint('Button pressed!');
                  final vm = Provider.of<StudyViewModel>(context, listen: false);
                  if (_elapsedSeconds > 0) {
                    await vm.uploadStudyDuration(_elapsedSeconds);
                  }
                   debugPrint('Button!!!');
                  GoRouter.of(context).go('/home');
                },
                horizontalPadding: 24,
                verticalPadding: 12,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
