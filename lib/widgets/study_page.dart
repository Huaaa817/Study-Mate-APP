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
  Widget? _backgroundWidget; // ✅ 緩存背景 widget

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
            GoRouterState.of(context).uri.queryParameters['duration'] ?? '10',
          ) ??
          10;
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
        // ✅ 只更新倒數數字，不動背景
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      }
    });
  }

  void _fetchBackgroundImage() async {
    try {
      final imageUrl = await fetchBackground();
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
      appBar: AppBar(title: const Text('學習')),
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
