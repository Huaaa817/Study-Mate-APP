import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/providers/study_duration_provider.dart';
import '/providers/background_provider.dart';
import '/view_models/me_wm.dart';

class StudySetPage extends StatelessWidget {
  const StudySetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final durationController = TextEditingController();

    // ✅ 預先載入背景圖片，並加上 log
    final userId = context.read<MeViewModel>().myId;
    final bgVM = context.read<BackgroundViewModel>();
    print('[LOG] StudySetPage: 強制預取最新背景...');
    bgVM.fetchBackground(userId, context).then((_) {
      if (bgVM.imageUrl != null) {
        print('[LOG] StudySetPage: ✅ 預取完成 imageUrl = ${bgVM.imageUrl}');
      } else {
        print('[LOG] StudySetPage: ❌ 預取失敗或無圖片');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Study')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '設定獎勵間隔時間（秒）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final duration = int.tryParse(durationController.text) ?? 0;
                if (duration > 0) {
                  context.read<StudyDurationProvider>().setDuration(duration);
                  GoRouter.of(context).go('/study?duration=$duration');
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('請輸入有效的時間')));
                }
              },
              child: const Text('確認'),
            ),
          ],
        ),
      ),
    );
  }
}
