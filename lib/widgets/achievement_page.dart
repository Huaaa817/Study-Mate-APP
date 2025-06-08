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

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_app/view_models/study_vm.dart';

// class AchievementPage extends StatefulWidget {
//   const AchievementPage({super.key});

//   @override
//   State<AchievementPage> createState() => _AchievementPageState();
// }

// class _AchievementPageState extends State<AchievementPage>
//     with SingleTickerProviderStateMixin {
//   late Future<Map<String, int>> _dailyLogsFuture;
//   late AnimationController _heartController;
//   late Animation<double> _heartAnimation;

//   @override
//   void initState() {
//     super.initState();
//     final studyVM = context.read<StudyViewModel>();
//     _dailyLogsFuture = studyVM.fetchDailyLogs().then((_) => studyVM.dailyLogs);

//     _heartController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     )..repeat(reverse: true);

//     _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//       CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _heartController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final studyVM = context.watch<StudyViewModel>();
//     final days = ['Mon', 'Tue', 'Wed', 'Thur', 'Fri', 'Sat', 'Sun'];
//     final now = DateTime.now();

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text('Achievement'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           // 背景圖
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/img/corridor.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // 玻璃模糊與內容
//           BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//             child: Container(
//               color: Colors.white.withOpacity(0.1),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: FutureBuilder<Map<String, int>>(
//                 future: _dailyLogsFuture,
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   final data = snapshot.data!;
//                   final List<BarChartGroupData> barGroups = [];

//                   for (int i = 0; i < 7; i++) {
//                     final day = now.subtract(Duration(days: 6 - i));
//                     final key = DateFormat('yyyy-MM-dd').format(day);
//                     final seconds = data[key] ?? 0;
//                     final hours = seconds / 3600;

//                     barGroups.add(BarChartGroupData(
//                       x: i,
//                       barRods: [
//                         BarChartRodData(
//                           toY: hours,
//                           color: Colors.redAccent,
//                           width: 18,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ],
//                     ));
//                   }

//                   return ListView(
//                     children: [
//                       const SizedBox(height: 80),
//                       _buildCard(
//                         child: Column(
//                           children: [
//                             const Text('Total Hours',
//                                 style: TextStyle(fontSize: 18)),
//                             SizedBox(
//                               height: 200,
//                               child: BarChart(
//                                 BarChartData(
//                                   titlesData: FlTitlesData(
//                                     leftTitles: AxisTitles(
//                                       sideTitles: SideTitles(showTitles: true),
//                                     ),
//                                     bottomTitles: AxisTitles(
//                                       sideTitles: SideTitles(
//                                         showTitles: true,
//                                         getTitlesWidget: (value, _) {
//                                           final index = value.toInt();
//                                           return Text(
//                                             days[index],
//                                             style:
//                                                 const TextStyle(fontSize: 12),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                   borderData: FlBorderData(show: false),
//                                   barGroups: barGroups,
//                                   gridData: FlGridData(show: false),
//                                   maxY: 10,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       _buildCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text('Achievement',
//                                 style: TextStyle(fontSize: 18)),
//                             const SizedBox(height: 8),
//                             Text('🍽️ Feeding frequency : ${studyVM.feed}'),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       _buildCard(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text('Mood',
//                                 style: TextStyle(fontSize: 18)),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 ScaleTransition(
//                                   scale: _heartAnimation,
//                                   child: const Icon(Icons.favorite,
//                                       color: Colors.pinkAccent, size: 24),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: LinearProgressIndicator(
//                                     value: studyVM.mood / 5,
//                                     backgroundColor: Colors.grey.shade300,
//                                     color: Colors.pinkAccent,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text('${studyVM.mood}'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Center(
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.brown[700],
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                           ),
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 24, vertical: 12),
//                             child: Text('Confirm'),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 50),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCard({required Widget child}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: child,
//     );
//   }
// }

