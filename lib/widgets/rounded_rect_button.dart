import 'package:flutter/material.dart';

class RoundedRectButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final double horizontalPadding;
  final double verticalPadding;
  final TextStyle? textStyle;

  const RoundedRectButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.borderRadius = 12.0,
    this.horizontalPadding = 24.0,
    this.verticalPadding = 12.0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondaryContainer, // 淡粉背景
        side: BorderSide(
          color: theme.colorScheme.secondary, // 深粉外框
          width: 2.5,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle ??
            TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
