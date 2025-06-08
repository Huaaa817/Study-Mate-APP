import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoTile extends StatelessWidget {
  final String title;
  final bool completed;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggle;
  final DateTime? dueDate;
  final VoidCallback onEdit;

  const TodoTile({
    super.key,
    required this.title,
    required this.completed,
    required this.onDelete,
    required this.onToggle,
    required this.onEdit,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateStr =
        dueDate != null
            ? '截止：${DateFormat('yyyy/MM/dd').format(dueDate!)}'
            : '';

    return Transform.rotate(
      angle: -0.02,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withOpacity(0.2),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: CustomPaint(
          foregroundPainter: LinePaperPainter(), // ⬅️ 改這裡！
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: completed,
                onChanged: onToggle,
                activeColor: scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration:
                            completed ? TextDecoration.lineThrough : null,
                        color:
                            completed
                                ? scheme.onSurface.withOpacity(0.5)
                                : scheme.onSurface,
                      ),
                    ),
                    if (dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '截止：${DateFormat('yyyy/MM/dd').format(dueDate!)}',
                          style: TextStyle(fontSize: 13, color: scheme.primary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -7), // 向上移動 4px
                    child: IconButton(
                      icon: Icon(Icons.edit, size: 20, color: scheme.primary),
                      onPressed: onEdit,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -7), // 向上移動 4px
                    child: IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Colors.grey),
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LinePaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1;

    const spacing = 24.0;
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class FoldedCornerPainter extends CustomPainter {
  final Color color;

  FoldedCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(size.width, size.height)
          ..lineTo(size.width - 20, size.height)
          ..lineTo(size.width, size.height - 20)
          ..close();

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
