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

  final List<Map<String, dynamic>> cards = [
    {
      'image': 'assets/pretty_studymate.png',
      'likeType': 'like',
      'describe': '讚',
    },
    {
      'image': 'assets/ugly_studymate.png',
      'likeType': 'dislike',
      'describe': '膚色不正常',
    },
    {
      'image': 'assets/processed_image.png',
      'likeType': 'like',
      'describe': '讚',
    },
    {
      'image': 'assets/studymate_dif.png',
      'likeType': 'dislike',
      'describe': '確保膚色一致',
    },
    {
      'image': 'assets/studymate_strange.png',
      'likeType': 'dislike',
      'describe': '確保身體比例一致',
    },
  ];

  void onSwipe(double dx) {
    setState(() {
      if (dx < 0) {
        dragX += dx;
        showHeart = dragX < -100;
      }
    });
  }

  void onEndSwipe() {
    setState(() {
      if (dragX < -100) {
        currentIndex = (currentIndex + 1) % cards.length;
      }
      dragX = 0;
      showHeart = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rotationAngle = dragX / screenWidth * 0.2;

    final currentCard = cards[currentIndex];
    final likeType = currentCard['likeType'];

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
                    Image.asset(currentCard['image'], fit: BoxFit.cover),

                    // 喜歡 / 不喜歡的 Icon（不含文字）
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Icon(
                        likeType == 'like' ? Icons.thumb_up : Icons.thumb_down,
                        color: likeType == 'like' ? Colors.green : Colors.red,
                        size: 32,
                        shadows: [
                          const Shadow(
                            blurRadius: 3,
                            color: Colors.black45,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),

                    // 說明文字（靠底部、可換行）
                    // 說明文字（靠底部、可換行，自動隨文字長度調整寬度）
                    Positioned(
                      bottom: 12,
                      left: 16, // 靠左邊一點
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          maxWidth: 250,
                        ), // 防止太長超出卡片
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '生成指南',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentCard['describe'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              softWrap: true,
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
        ),
      ),
    );
  }
}
