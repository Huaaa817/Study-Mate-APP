import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';

class StudySetPage extends StatelessWidget {
  const StudySetPage({super.key}); // const

  @override
  Widget build(BuildContext context) {
    final durationController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('學習設定')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '設定學習時間（秒）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final duration = int.tryParse(durationController.text) ?? 0;
                if (duration > 0) {
                  GoRouter.of(context).go('/study?duration=$duration');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('請輸入有效的時間')),
                  );
                }
              },
              child: const Text('確認'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}