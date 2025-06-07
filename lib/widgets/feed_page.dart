import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/providers/study_duration_provider.dart';
import 'package:flutter_app/view_models/feed_vm.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  int _imageIndex = 0;
  List<String>? _imagePaths;
  bool _initialized = false;

  // @override
  // void initState() {
  //   super.initState();

  //   // 確保 context 可用後再初始化圖片列表
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final duration = context.read<StudyDurationProvider>().duration;

  //     if (duration >= 35) {
  //       _imagePaths = [
  //         'assets/img/meat1.jpg',
  //         'assets/img/meat2.jpg',
  //         'assets/img/meat3.jpg',
  //         'assets/img/meat4.jpg',
  //       ];
  //     } else if (duration >= 25) {
  //       _imagePaths = [
  //         'assets/img/ice_cream1.jpg',
  //         'assets/img/ice_cream2.jpg',
  //         'assets/img/ice_cream3.jpg',
  //         'assets/img/ice_cream4.jpg',
  //       ];
  //     } else {
  //       _imagePaths = [
  //         'assets/img/momo1.jpg',
  //         'assets/img/momo2.jpg',
  //         'assets/img/momo3.jpg',
  //         'assets/img/momo4.jpg',
  //       ];
  //     }

  //     setState(() {
  //       _initialized = true;
  //     });
  //   });
  // }
  @override
    void initState() {
      super.initState();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final duration = context.read<StudyDurationProvider>().duration;

        if (duration >= 35) {
          _imagePaths = [
            'assets/img/meat1.jpg',
            'assets/img/meat2.jpg',
            'assets/img/meat3.jpg',
            'assets/img/meat4.jpg',
          ];
        } else if (duration >= 25) {
          _imagePaths = [
            'assets/img/ice_cream1.jpg',
            'assets/img/ice_cream2.jpg',
            'assets/img/ice_cream3.jpg',
            'assets/img/ice_cream4.jpg',
          ];
        } else {
          _imagePaths = [
            'assets/img/momo1.jpg',
            'assets/img/momo2.jpg',
            'assets/img/momo3.jpg',
            'assets/img/momo4.jpg',
          ];
        }

        // 新增計數呼叫
        await context.read<FeedViewModel>().addFeedCount();
        debugPrint('add feed count');

        setState(() {
          _initialized = true;
        });
      });
    }


  void _handleButtonPress() {
    if (_imagePaths == null) return;

    if (_imageIndex < _imagePaths!.length - 1) {
      setState(() {
        _imageIndex++;
      });
    } else {
      // final duration = context.read<StudyDurationProvider>().duration;
      // GoRouter.of(context).go('/study?duration=$duration');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast =
        _imagePaths != null && _imageIndex == (_imagePaths!.length - 1);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      //appBar: AppBar(title: const Text('Feed')),
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: scheme.primary, // buildColorTile('primary')
        foregroundColor: scheme.onPrimary, // buildColorTile('onPrimary')
      ),
      body: Center(
        child:
            !_initialized || _imagePaths == null
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '來餵食study mate吧！',
                      style: TextStyle(
                        fontSize: 24,
                        color:
                            scheme
                                .onBackground, // buildColorTile('onBackground')
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      _imagePaths![_imageIndex],
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            scheme.secondaryContainer, // 'secondaryContainer'
                        foregroundColor:
                            scheme
                                .onSecondaryContainer, // 'onSecondaryContainer'
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _handleButtonPress,
                      child: Text(isLast ? '返回學習' : 'feed'),
                    ),
                  ],
                ),
      ),
    );
  }
}
