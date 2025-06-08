import 'package:flutter/material.dart';

class SwipeCard extends StatefulWidget {
  const SwipeCard({super.key});

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  int currentIndex = 0;
  double dragX = 0;
  bool showHeart = false;

  final List<String> images = [
    'assets/img/meat1.jpg',
    'assets/img/meat2.jpg',
    'assets/img/meat3.jpg',
  ];

  void onSwipe(double dx) {
    setState(() {
      // 只累積負的dx（左滑）
      if (dx < 0) {
        dragX += dx;
        // 你要顯示什麼圖示也可以改這裡，我這裡範例改成左滑超過100顯示心形
        showHeart = dragX < -100;
      }
      // 往右滑不做事
    });
  }

  void onEndSwipe() {
    setState(() {
      // 左滑超過 -100 就換下一張
      if (dragX < -100) {
        currentIndex = (currentIndex + 1) % images.length;
      }
      dragX = 0;
      showHeart = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rotationAngle = dragX / screenWidth * 0.2;

    return Center(
      child: GestureDetector(
        onHorizontalDragUpdate: (details) => onSwipe(details.delta.dx),
        onHorizontalDragEnd: (_) => onEndSwipe(),
        child: Transform.translate(
          offset: Offset(dragX, 0),
          child: Transform.rotate(
            angle: rotationAngle,
            child: SizedBox(
              width: screenWidth * 0.7,
              height: screenWidth * 0.9,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Image.asset(images[currentIndex], fit: BoxFit.cover),
                    // 如果要顯示心形，可在這裡加一個條件顯示的 Positioned Icon
                    if (showHeart)
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
