import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/view_models/study_vm.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  DateTime _selectedDate = DateTime.now();

  // 取得當週周一日期（方便繪製週圖表）
  DateTime get _startOfWeek {
    final weekday = _selectedDate.weekday; // 1=Mon, 7=Sun
    return _selectedDate.subtract(Duration(days: weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _loadDataForDate(_selectedDate);
    context.read<StudyViewModel>().fetchWeeklyLogs();
  }

  void _loadDataForDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final studyVM = context.read<StudyViewModel>();
    studyVM.fetchDataByDate(formattedDate);
    studyVM.fetchWeeklyLogs();
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

  // 左箭頭：往前一天
  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _loadDataForDate(_selectedDate);
  }

  // 右箭頭：往後一天
  void _nextDay() {
    if (_selectedDate.isBefore(DateTime.now())) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
      _loadDataForDate(_selectedDate);
    }
  }

//   @override
//   Widget build(BuildContext context) {
//     final studyVM = context.watch<StudyViewModel>();

//     final hours = studyVM.seconds ~/ 3600;
//     final minutes = (studyVM.seconds % 3600) ~/ 60;
//     final seconds = studyVM.seconds % 60;

//     final theme = Theme.of(context);

//     // 取得本週每天的讀書秒數資料
//     // 假設 studyVM 有方法：fetchWeeklyData(DateTime startOfWeek) 回傳 Map<String, int> (key=yyyy-MM-dd)
//     // 為簡化示範，這裡直接從 dailyLogs 撈資料
//     final Map<String, int> weeklyData = {};
//     for (int i = 0; i < 7; i++) {
//       final day = _startOfWeek.add(Duration(days: i));
//       final key = DateFormat('yyyy-MM-dd').format(day);
//       weeklyData[key] = studyVM.weeklyLogs[key] ?? 0;
//     }

//     // 週日文字縮寫
//     const weekDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

//     // 心情值最大分成 5 格
//     final moodValue = studyVM.mood.clamp(0, 5);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Achievement'),
//         backgroundColor: Theme.of(context).colorScheme.primary, // buildColorTile('primary')
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.calendar_today),
//             onPressed: _pickDate,
//             tooltip: '選擇日期',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 日期選擇區塊：左箭頭 日期 右箭頭
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_left, color: theme.primaryColor),
//                   onPressed: _previousDay,
//                   tooltip: '前一天',
//                 ),
//                 GestureDetector(
//                   onTap: _pickDate,
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: theme.primaryColor),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       DateFormat('yyyy-MM-dd').format(_selectedDate),
//                       style: theme.textTheme.titleMedium
//                           ?.copyWith(color: theme.primaryColor),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.arrow_right, color: theme.primaryColor),
//                   onPressed: _nextDay,
//                   tooltip: '後一天',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // // 一整週柱狀圖
//             SizedBox(
//               height: 180,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: List.generate(7, (index) {
//                   final day = _startOfWeek.add(Duration(days: index));
//                   final key = DateFormat('yyyy-MM-dd').format(day);
//                   final seconds = weeklyData[key] ?? 0;

//                   // 柱狀圖最大高度（像素）
//                   const maxBarHeight = 120.0;

//                   // 計算最高秒數，避免除以 0
//                   final maxSeconds =
//                       weeklyData.values.isNotEmpty ? weeklyData.values.reduce((a, b) => a > b ? a : b) : 1;

//                   // 計算柱狀高度
//                   final barHeight =
//                       maxSeconds == 0 ? 4.0 : (seconds / maxSeconds) * maxBarHeight;

//                   // 判斷是否為選取日期
//                   final isSelected = key == DateFormat('yyyy-MM-dd').format(_selectedDate);

//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       // 顯示累積小時（1小時以下顯示分鐘）
//                       if (seconds > 0)
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 4),
//                           child: Text(
//                             seconds >= 3600
//                                 ? '${(seconds / 3600).toStringAsFixed(1)}h'
//                                 : '${(seconds / 60).toStringAsFixed(1)}m',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: isSelected
//                                   ? theme.primaryColorDark
//                                   : theme.disabledColor,
//                             ),
//                           ),
//                         ),
//                       // 柱狀圖
//                       Container(
//                         width: 20.0,
//                         height: barHeight < 4.0 ? 4.0 : barHeight,
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? theme.primaryColor
//                               : theme.primaryColorLight,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       // 星期縮寫
//                       Text(
//                         weekDayLabels[index],
//                         style: TextStyle(
//                           color: isSelected
//                               ? theme.primaryColorDark
//                               : theme.disabledColor,
//                           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // 累積時間與心情條
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 12.0), // 👈 稍微往右一點
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '累積讀書時間',
//                       style: theme.textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '$hours 小時 $minutes 分 $seconds 秒',
//                       style: theme.textTheme.bodyLarge,
//                     ),
//                     const SizedBox(height: 24),

//                     Text(
//                       '心情值',
//                       style: theme.textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 8),

//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: List.generate(5, (index) {
//                         final isFilled = index < moodValue;
//                         return Container(
//                           margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
//                           width: 36.0,
//                           height: 16.0,
//                           decoration: BoxDecoration(
//                             color: isFilled
//                                 ? theme.primaryColor
//                                 : theme.primaryColorLight.withOpacity(0.4),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         );
//                       }),
//                     ),

//                     const SizedBox(height: 24),

//                     Text(
//                       '餵食次數',
//                       style: theme.textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '${studyVM.feed}',
//                       style: theme.textTheme.bodyLarge,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
@override
Widget build(BuildContext context) {
  final studyVM = context.watch<StudyViewModel>();

  final hours = studyVM.seconds ~/ 3600;
  final minutes = (studyVM.seconds % 3600) ~/ 60;
  final seconds = studyVM.seconds % 60;

  final theme = Theme.of(context);

  final Map<String, int> weeklyData = {};
  for (int i = 0; i < 7; i++) {
    final day = _startOfWeek.add(Duration(days: i));
    final key = DateFormat('yyyy-MM-dd').format(day);
    weeklyData[key] = studyVM.weeklyLogs[key] ?? 0;
  }

  const weekDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final moodValue = studyVM.mood.clamp(0, 5);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Achievement'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _pickDate,
          tooltip: '選擇日期',
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 日期選擇區塊
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left, color: theme.primaryColor),
                onPressed: _previousDay,
                tooltip: '前一天',
              ),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.primaryColor),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right, color: theme.primaryColor),
                onPressed: _nextDay,
                tooltip: '後一天',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 週圖表，只有選取的柱狀圖進行動畫
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final day = _startOfWeek.add(Duration(days: index));
                final key = DateFormat('yyyy-MM-dd').format(day);
                final seconds = weeklyData[key] ?? 0;

                const maxBarHeight = 120.0;
                final maxSeconds =
                    weeklyData.values.isNotEmpty ? weeklyData.values.reduce((a, b) => a > b ? a : b) : 1;
                final barHeight = maxSeconds == 0 ? 4.0 : (seconds / maxSeconds) * maxBarHeight;

                final isSelected = key == DateFormat('yyyy-MM-dd').format(_selectedDate);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 顯示累積小時
                    if (seconds > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          seconds >= 3600
                              ? '${(seconds / 3600).toStringAsFixed(1)}h'
                              : '${(seconds / 60).toStringAsFixed(1)}m',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? theme.primaryColorDark
                                : theme.disabledColor,
                          ),
                        ),
                      ),
                    // 只有選擇的日期會顯示動畫
                    isSelected
                        ? TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: barHeight < 4.0 ? 4.0 : barHeight),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return Container(
                                width: 20.0,
                                height: value,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.primaryColorLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 20.0,
                            height: barHeight < 4.0 ? 4.0 : barHeight,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor
                                  : theme.primaryColorLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                    const SizedBox(height: 8),
                    // 星期縮寫
                    Text(
                      weekDayLabels[index],
                      style: TextStyle(
                        color: isSelected
                            ? theme.primaryColorDark
                            : theme.disabledColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

          // 累積時間與心情條
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '累積讀書時間',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$hours 小時 $minutes 分 $seconds 秒',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    '心情值',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final isFilled = index < moodValue;
                      return Container(
                        margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                        width: 36.0,
                        height: 16.0,
                        decoration: BoxDecoration(
                          color: isFilled
                              ? theme.primaryColor
                              : theme.primaryColorLight.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '餵食次數',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${studyVM.feed}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



 }
