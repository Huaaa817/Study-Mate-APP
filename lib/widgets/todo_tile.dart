import 'package:flutter/material.dart';

class TodoTile extends StatelessWidget {
  final String title;
  final bool completed;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggle;

  const TodoTile({
    super.key,
    required this.title,
    required this.completed,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Checkbox(value: completed, onChanged: onToggle),
        title: Text(
          title,
          style: TextStyle(
            decoration:
                completed ? TextDecoration.lineThrough : TextDecoration.none,
            color:
                completed
                    ? scheme.onSurface.withOpacity(0.5)
                    : scheme.onBackground,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: scheme.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
