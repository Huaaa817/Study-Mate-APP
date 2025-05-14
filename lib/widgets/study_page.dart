import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/services/fetch_background.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with WidgetsBindingObserver {
  late int _durationInterval; // 每次跳轉 feed 的時間間隔
  int _elapsedSeconds = 0; // 累積時間
  Timer? _timer;
  bool _initialized = false;
  String? backgroundImageUrl;
  Widget? _backgroundWidget;

  static int _sceneIndex = 0;
  final List<String> _sceneDescriptions = [
    "A quiet university courtyard in the early morning...",
    "A cozy rooftop under a starry night sky...",
    "A riverside path beneath blooming cherry blossom trees...",
    "An indoor Japanese-style study room with tatami flooring...",
    "A peaceful grassy field under soft golden sunlight...",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 加入 observer
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
      _fetchBackgroundImage();
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
        _timer?.cancel(); // 停止計時器，避免回來後重啟兩個
        _timer = null;

        // 用 push 疊頁，feed 回來後不會重建
        // GoRouter.of(context).push('/feed?duration=$_durationInterval');
        GoRouter.of(context).push('/feed?duration=$_durationInterval').then((
          _,
        ) {
          // 當從 feed page 返回時
          if (mounted) _startTimer();
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除 observer
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = remainingSeconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void _fetchBackgroundImage() async {
    try {
      final String description = _sceneDescriptions[_sceneIndex];
      _sceneIndex = (_sceneIndex + 1) % _sceneDescriptions.length;

      final imageUrl = await fetchBackground(description: description);
      Widget imageWidget;

      if (imageUrl.startsWith('data:image')) {
        final base64Data = imageUrl.split(',').last;
        final Uint8List bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        imageWidget = Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.red),
            );
          },
        );
      }

      setState(() {
        backgroundImageUrl = imageUrl;
        _backgroundWidget = imageWidget;
      });
    } catch (e) {
      print("Failed to fetch background image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          if (_backgroundWidget != null) _backgroundWidget!,
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
        ],
      ),
    );
  }
}
