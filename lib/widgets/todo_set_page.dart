import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/widgets/rounded_rect_button.dart';

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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Setting'),
        backgroundColor: scheme.primary, // buildColorTile('primary')
        foregroundColor: scheme.onPrimary, // buildColorTile('onPrimary')
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                '有什麼事情要做呢？',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // 📅 日期按鈕（移到上方、拿掉外框、靠左）
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(dateText),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 📝 多行輸入框
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 4,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '輸入你的待辦事項',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: scheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: scheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: scheme.outline, width: 2),
                ),
              ),
              onSubmitted: (_) => _handleAdd(),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedRectButton(
                  text: '確認',
                  onPressed: _handleAdd,
                  borderRadius: 20,
                  horizontalPadding: 24,
                  verticalPadding: 12,
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
