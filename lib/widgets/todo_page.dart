import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';
import 'package:flutter_app/widgets/todo_set_page.dart';
import 'package:flutter_app/widgets/todo_tile.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Map<String, dynamic>> _todos = [];

  void _addTodo(String title) {
    setState(() {
      _todos.add({'title': title, 'completed': false});
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _toggleCompleted(int index, bool? value) {
    setState(() {
      _todos[index]['completed'] = value ?? false;
    });
  }

  void _openAddTodoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TodoSetPage(onAdd: _addTodo)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _todos.isEmpty
                ? const Center(child: Text('尚無待辦事項'))
                : ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    final todo = _todos[index];
                    return TodoTile(
                      title: todo['title'],
                      completed: todo['completed'],
                      onDelete: () => _removeTodo(index),
                      onToggle: (val) => _toggleCompleted(index, val),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTodoPage,
        child: const Icon(Icons.add),
      ),
      //bottomNavigationBar: AppBottomNavigationBar(),
    );
  }
}
