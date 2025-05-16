import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ZoomedFourPanelAnimation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ZoomedFourPanelAnimation extends StatefulWidget {
  @override
  _ZoomedFourPanelAnimationState createState() =>
      _ZoomedFourPanelAnimationState();
}

class _ZoomedFourPanelAnimationState extends State<ZoomedFourPanelAnimation> {
  int _frame = 0;
  late Timer _timer;

  final List<Alignment> _alignments = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomLeft,
    Alignment.bottomRight,
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        _frame = (_frame + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ClipRect(
          child: Align(
            alignment: _alignments[_frame],
            widthFactor: 0.5,
            heightFactor: 0.5,
            child: Transform.scale(
              scale: 1.0, // 放大2倍來讓四分之一填滿
              child: Image.asset('assets/processed_image.png'),
            ),
          ),
        ),
      ),
    );
  }
}
