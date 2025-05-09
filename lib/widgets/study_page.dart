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

class _StudyPageState extends State<StudyPage> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _initialized = false;
  String? backgroundImageUrl;
  Widget? _backgroundWidget; //緩存背景 widget

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final duration =
          int.tryParse(
            GoRouterState.of(context).uri.queryParameters['duration'] ?? '60',
          ) ??
          60;
      _remainingSeconds = duration;
      _startTimer();
      _fetchBackgroundImage();
      _initialized = true;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        GoRouter.of(context).go('/feed');
      } else {
        // 只更新倒數數字，不動背景
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      }
    });
  }

  static int _sceneIndex = 0; // 從 0 開始
  final List<String> _sceneDescriptions = [
    "A quiet university courtyard in the early morning. The sun casts soft golden light through the trees, and gentle shadows stretch across stone paths and study benches. Ivy climbs the walls of surrounding buildings, and a fountain quietly bubbles in the background.",
    "A cozy rooftop under a starry night sky, decorated with string lights and a distant view of school buildings. The mood is serene and introspective, with gentle night tones.",
    "A riverside path beneath blooming cherry blossom trees. Petals fall softly onto a clean walkway, with a study bench nearby and calm water reflecting the pink sky.",
    "An indoor Japanese-style study room with tatami flooring, shoji sliding doors, and warm ambient lighting. Outside the window is a small zen garden with raked gravel and bonsai trees.",
    "A peaceful grassy field under soft golden sunlight. The space feels wide, bright, and grounded in nature. There is a gentle breeze and a feeling of quiet clarity, suitable for peaceful focus.",
  ];
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('學習')),
      body: Stack(
        children: [
          if (_backgroundWidget != null) _backgroundWidget!,
          Container(
            color: Colors.black.withOpacity(0.4), // 讓文字清楚
            alignment: Alignment.center,
            child: Text(
              '剩餘時間：$_remainingSeconds 秒',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
