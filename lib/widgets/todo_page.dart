import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/widgets/todo_set_page.dart';
import 'package:flutter_app/widgets/todo_tile.dart';
import 'package:flutter_app/view_models/todo_list_vm.dart';
import 'package:flutter_app/widgets/todo_rewards_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  int _completedCount = 0;

  void _openAddTodoPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TodoSetPage(
              onAdd: (title, dueDate) {
                final vm = Provider.of<TodoListViewModel>(
                  context,
                  listen: false,
                );
                vm.addTodo(title, dueDate: dueDate);
              },
            ),
      ),
    );
  }

  void _openEditTodoPage(BuildContext context, Map<String, dynamic> todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TodoSetPage(
              initialTitle: todo['title'],
              initialDueDate: todo['dueDate']?.toDate(),
              onAdd: (newTitle, newDueDate) {
                final vm = Provider.of<TodoListViewModel>(
                  context,
                  listen: false,
                );
                vm.updateTodo(todo['id'], newTitle, newDueDate);
              },
            ),
      ),
    );
  }

  void _handleToggle(BuildContext context, String id, bool newValue) async {
    final vm = Provider.of<TodoListViewModel>(context, listen: false);
    await vm.toggleTodo(id, newValue);

    if (newValue) {
      _completedCount++;
    } else {
      _completedCount = (_completedCount > 0) ? _completedCount - 1 : 0;
    }

    if (_completedCount >= 2) {
      _completedCount = 0;
      debugPrint('✅ 獎勵條件觸發，即將跳轉 rewards page');
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TodoRewardsPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<TodoListViewModel>(context);
    final todos = vm.todos;

    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            todos.isEmpty
                ? const Center(child: Text('尚無待辦事項'))
                : ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return TodoTile(
                      title: todo['title'],
                      completed: todo['completed'],
                      dueDate: todo['dueDate']?.toDate(),
                      onDelete: () => vm.deleteTodo(todo['id']),
                      onToggle:
                          (val) =>
                              _handleToggle(context, todo['id'], val ?? false),
                      onEdit: () => _openEditTodoPage(context, todo),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTodoPage(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
