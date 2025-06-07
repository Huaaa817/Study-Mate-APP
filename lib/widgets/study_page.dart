import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/view_models/me_wm.dart';
import '/providers/background_provider.dart';
import 'package:flutter_app/view_models/study_vm.dart';

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
          ) ??
          60;

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

        GoRouter.of(context).push('/feed?duration=$_durationInterval').then((
          _,
        ) {
          if (mounted) _startTimer();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    Provider.of<StudyViewModel>(
      context,
      listen: false,
    ).uploadStudyDuration(_elapsedSeconds);

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

          // 將圖片放底部中央，顯示左上角四分之一並放大兩倍
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

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '累積專注時間：${_formatTime(_elapsedSeconds)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final vm = Provider.of<StudyViewModel>(
                    context,
                    listen: false,
                  );

                  if (_elapsedSeconds > 0) {
                    await vm.uploadStudyDuration(_elapsedSeconds);
                  }
                  GoRouter.of(context).go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('結束專注', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
