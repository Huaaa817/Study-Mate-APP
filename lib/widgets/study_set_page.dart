import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/providers/study_duration_provider.dart';
import '/providers/background_provider.dart';
import '/view_models/me_wm.dart';
import 'package:flutter_app/widgets/rounded_rect_button.dart';

class StudySetPage extends StatefulWidget {
  const StudySetPage({super.key});

  @override
  State<StudySetPage> createState() => _StudySetPageState();
}

class _StudySetPageState extends State<StudySetPage> {
  int selectedMinute = 0;
  int selectedSecond = 10;

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                '設定獎勵間隔時間',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMinute,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            selectedMinute = index;
                          });
                        },
                        children: List<Widget>.generate(60, (int index) {
                          return Center(child: Text('$index 分'));
                        }),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedSecond,
                        ),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            selectedSecond = index;
                          });
                        },
                        children: List<Widget>.generate(60, (int index) {
                          return Center(child: Text('$index 秒'));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {}); // 更新畫面
                    },
                    child: const Text('確認'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<MeViewModel>().myId;
    final bgVM = context.read<BackgroundViewModel>();
    bgVM.fetchBackground(userId, context);

    final displayText =
        '${selectedMinute.toString().padLeft(2, '0')} 分 ${selectedSecond.toString().padLeft(2, '0')} 秒';

    return Scaffold(
      appBar: AppBar(title: const Text('Study setting')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(displayText),
                  onPressed: _showTimePicker,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedRectButton(
                  text: '確認',
                  onPressed: () {
                    final totalSeconds = selectedMinute * 60 + selectedSecond;
                    if (totalSeconds > 0) {
                      context.read<StudyDurationProvider>().setDuration(
                        totalSeconds,
                      );
                      GoRouter.of(context).go('/study?duration=$totalSeconds');
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('請選擇有效的時間')));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
