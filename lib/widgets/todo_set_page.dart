import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoSetPage extends StatefulWidget {
  final Function(String, DateTime?) onAdd;
  final String? initialTitle;
  final DateTime? initialDueDate;

  const TodoSetPage({
    super.key,
    required this.onAdd,
    this.initialTitle,
    this.initialDueDate,
  });

  @override
  State<TodoSetPage> createState() => _TodoSetPageState();
}

class _TodoSetPageState extends State<TodoSetPage> {
  late TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle ?? '');
    _selectedDate = widget.initialDueDate;
  }

  void _handleAdd() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請輸入待辦事項')));
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請選擇完成日期')));
      return;
    }

    widget.onAdd(text, _selectedDate);
    Navigator.pop(context);
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        _selectedDate != null
            ? '截止：${DateFormat('yyyy/MM/dd').format(_selectedDate!)}'
            : '選擇完成日期';

    return Scaffold(
      appBar: AppBar(title: const Text('編輯待辦')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '待辦內容',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _handleAdd(),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(dateText),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _handleAdd, child: const Text('確認')),
          ],
        ),
      ),
    );
  }
}
