import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/fetch_study_mate.dart';

void main() => runApp(MaterialApp(home: AnimatedImageFromFlow()));

class AnimatedImageFromFlow extends StatefulWidget {
  @override
  _AnimatedImageFromFlowState createState() => _AnimatedImageFromFlowState();
}

class _AnimatedImageFromFlowState extends State<AnimatedImageFromFlow> {
  Uint8List? _imageBytes;
  int _currentFrame = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadImageFromFlow();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      setState(() {
        _currentFrame = (_currentFrame + 1) % 4;
      });
    });
  }

  Future<void> _loadImageFromFlow() async {
    try {
      print('1. 呼叫 Flow 獲取圖片...');
      final data = await fetchStudyMateImage(
        'long',
        'black',
        'wavy',
        'hat',
        'light',
        'happy',
        'calm',
        'friendly',
        'creative',
        'Add sunglasses',
      );

      String base64Str = data['imageBase64'] as String;

      // 去除 base64 前綴（如果有）
      if (base64Str.startsWith('data:image')) {
        final commaIndex = base64Str.indexOf(',');
        base64Str = base64Str.substring(commaIndex + 1);
      }

      final Uint8List imageBytes = base64Decode(base64Str);
      setState(() {
        _imageBytes = imageBytes;
      });
    } catch (e) {
      print('獲取圖片失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageBytes == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 顯示圖片四宮格之一
    return Scaffold(
      body: Center(
        child: ClipRect(
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final double scale = 2.0; // 放大 2 倍，讓 1/4 圖片剛好填滿

                // 計算 offset
                final dx = (_currentFrame % 2) * width / 2;
                final dy = (_currentFrame ~/ 2) * height / 2;

                return Transform(
                  transform:
                      Matrix4.identity()
                        ..scale(scale, scale)
                        ..translate(-dx, -dy),
                  child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
