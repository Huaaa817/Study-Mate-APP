import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/view_models/study_vm.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studyVM = Provider.of<StudyViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievement')),
      body: FutureBuilder<Map<String, int>>(
        future: studyVM.fetchDailyLogs().then((_) {
          final logs = studyVM.dailyLogs;
          //print('✅ [DEBUG] 取得 dailyLogs 共 ${logs.length} 筆：');
          for (var entry in logs.entries) {
            print('📅 ${entry.key} => ${entry.value} 秒');
          }
          return logs;
        }),
        builder: (context, snapshot) {
          print('⏳ [DEBUG] Snapshot 狀態：${snapshot.connectionState}');

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('❌ [DEBUG] Snapshot 發生錯誤：${snapshot.error}');
            return Center(child: Text('發生錯誤：${snapshot.error}'));
          }

          final logs = snapshot.data ?? {};

          if (logs.isEmpty) {
            print('⚠️ [DEBUG] snapshot.data 為空，顯示尚無紀錄');
            return const Center(child: Text('目前尚無讀書紀錄'));
          }

          //print('✅ [DEBUG] 開始渲染 ${logs.length} 筆紀錄');
          return ListView(
            padding: const EdgeInsets.all(16),
            children:
                logs.entries.map((entry) {
                  final date = entry.key;
                  final totalSeconds = entry.value;
                  final hours = totalSeconds ~/ 3600;
                  final minutes = (totalSeconds % 3600) ~/ 60;
                  final seconds = totalSeconds % 60;

                  final formattedTime = '${hours} 小時 ${minutes} 分 ${seconds} 秒';

                  return ListTile(
                    title: Text('📅 $date'),
                    subtitle: Text('🕒 今日累積：$formattedTime'),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
