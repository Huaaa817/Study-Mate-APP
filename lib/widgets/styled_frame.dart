import 'package:flutter/material.dart';
import 'styled_text.dart';

class StyledFrame extends StatelessWidget {
  final String label;
  final String content;
  final Color backgroundColor;
  final double fontSize;

  const StyledFrame({
    required this.label,
    required this.content,
    this.backgroundColor = Colors.grey,
    this.fontSize = 18,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StyledText("$label:", color: Colors.black87, fontSize: 22),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: StyledText(content, color: Colors.black87, fontSize: fontSize),
        ),
      ],
    );
  }
}
