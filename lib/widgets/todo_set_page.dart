import 'package:flutter/material.dart';

class TodoSetPage extends StatefulWidget {
  final Function(String) onAdd;

  const TodoSetPage({super.key, required this.onAdd});

  @override
  State<TodoSetPage> createState() => _TodoSetPageState();
}

class _TodoSetPageState extends State<TodoSetPage> {
  final TextEditingController _controller = TextEditingController();

  void _handleAdd() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd(text);
      Navigator.pop(context); // 返回前頁
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新增待辦')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '輸入待辦事項',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _handleAdd(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _handleAdd, child: const Text('新增')),
          ],
        ),
      ),
    );
  }
}
