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

    return Card(
      child: ListTile(
        leading: Checkbox(value: completed, onChanged: onToggle),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                decoration:
                    completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                color:
                    completed
                        ? scheme.onSurface.withOpacity(0.5)
                        : scheme.onBackground,
              ),
            ),
            if (dueDate != null)
              Text(dateStr, style: TextStyle(color: scheme.primary)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: scheme.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
