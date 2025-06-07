// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_app/view_models/study_vm.dart';

// class AchievementPage extends StatelessWidget {
//   const AchievementPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final studyVM = Provider.of<StudyViewModel>(context, listen: false);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Achievement')),
//       body: FutureBuilder<Map<String, int>>(
//         future: studyVM.fetchDailyLogs().then((_) {
//           final logs = studyVM.dailyLogs;
//           //print('✅ [DEBUG] 取得 dailyLogs 共 ${logs.length} 筆：');
//           for (var entry in logs.entries) {
//             print('📅 ${entry.key} => ${entry.value} 秒');
//           }
//           return logs;
//         }),
//         builder: (context, snapshot) {
//           print('⏳ [DEBUG] Snapshot 狀態：${snapshot.connectionState}');

//           if (snapshot.connectionState != ConnectionState.done) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             print('❌ [DEBUG] Snapshot 發生錯誤：${snapshot.error}');
//             return Center(child: Text('發生錯誤：${snapshot.error}'));
//           }

//           final logs = snapshot.data ?? {};

//           if (logs.isEmpty) {
//             print('⚠️ [DEBUG] snapshot.data 為空，顯示尚無紀錄');
//             return const Center(child: Text('目前尚無讀書紀錄'));
//           }

//           //print('✅ [DEBUG] 開始渲染 ${logs.length} 筆紀錄');
//           return ListView(
//             padding: const EdgeInsets.all(16),
//             children:
//                 logs.entries.map((entry) {
//                   final date = entry.key;
//                   final totalSeconds = entry.value;
//                   final hours = totalSeconds ~/ 3600;
//                   final minutes = (totalSeconds % 3600) ~/ 60;
//                   final seconds = totalSeconds % 60;

//                   final formattedTime = '${hours} 小時 ${minutes} 分 ${seconds} 秒';

//                   return ListTile(
//                     title: Text('📅 $date'),
//                     subtitle: Text('🕒 今日累積：$formattedTime'),
//                   );
//                 }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/view_models/study_vm.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDataForDate(_selectedDate);
  }

  void _loadDataForDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final studyVM = context.read<StudyViewModel>();
    studyVM.fetchDataByDate(formattedDate);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadDataForDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyVM = context.watch<StudyViewModel>();

    final hours = studyVM.seconds ~/ 3600;
    final minutes = (studyVM.seconds % 3600) ~/ 60;
    final seconds = studyVM.seconds % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '日期：${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text('累積讀書時間：$hours 小時 $minutes 分 $seconds 秒'),
            const SizedBox(height: 8),
            Text('心情值：${studyVM.mood}'),
            const SizedBox(height: 8),
            Text('餵食次數：${studyVM.feed}'),
          ],
        ),
      ),
    );
  }
}
