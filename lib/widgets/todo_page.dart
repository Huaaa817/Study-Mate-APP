import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';
import 'package:go_router/go_router.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();

  // 使用 Map 來記錄每個 todo 的狀態
  final List<Map<String, dynamic>> _todos = [];

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _todos.add({'title': text, 'completed': false});
        _controller.clear();
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: '輸入待辦事項',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _addTodo, child: const Text('新增')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _todos.isEmpty
                      ? const Center(child: Text('尚無待辦事項'))
                      : ListView.builder(
                        itemCount: _todos.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: _todos[index]['completed'],
                                onChanged:
                                    (value) => _toggleCompleted(index, value),
                              ),
                              title: Text(
                                _todos[index]['title'],
                                style: TextStyle(
                                  decoration:
                                      _todos[index]['completed']
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                  color:
                                      _todos[index]['completed']
                                          ? Colors.grey
                                          : Colors.black,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeTodo(index),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(),
    );
  }
}
