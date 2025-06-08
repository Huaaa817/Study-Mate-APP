import 'package:flutter/material.dart';

class CircleImageButton extends StatelessWidget {
  final String imagePath;
  final double size;
  final VoidCallback onPressed;

  const CircleImageButton({
    Key? key,
    required this.imagePath,
    required this.onPressed,
    this.size = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double imageSize = size * 0.7; // 圖片比容器小20%

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primaryContainer, // 淺粉紅背景
        ),
        alignment: Alignment.center,
        child: ClipOval(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            width: imageSize,
            height: imageSize,
          ),
        ),
      ),
    );
  }
}
