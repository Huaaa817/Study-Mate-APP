import 'package:flutter/material.dart';
import 'package:flutter_app/services/fetch_chat.dart';
import 'package:flutter_app/view_models/me_wm.dart';
import 'package:flutter_app/services/authentication.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/view_models/mood_vm.dart';

class HomePage extends StatefulWidget {
  final MeViewModel viewModel;
  const HomePage({super.key, required this.viewModel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Future<String>? _greetingFuture;
  bool _hasShownImageDialog = false;

  late AnimationController _heartController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _greetingFuture = getGreeting();
    _checkDialogShownThenLoadImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodViewModel>().updateMood();
      debugPrint('Calling updateMood...');
    });
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // 自動來回動畫

    _scaleAnimation = Tween(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
  }

  Future<String> getGreeting() async {
    final userId = widget.viewModel.me?.id ?? widget.viewModel.myId;
    const personality = "可愛";
    return await fetchGreeting(personality, userId);
  }

  Future<void> _checkDialogShownThenLoadImage() async {
    final prefs = await SharedPreferences.getInstance();
    _hasShownImageDialog = prefs.getBool('hasShownImageDialog') ?? false;

    await _loadUserImage();

    if (!_hasShownImageDialog) {
      await prefs.setBool('hasShownImageDialog', true);
    }
  }

  void _showLoadingDialog() {
    if (!_hasShownImageDialog) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => const AlertDialog(
              title: Text('圖片載入中'),
              content: Text('請稍候...'),
            ),
      );
    }
  }

  void _hideLoadingDialog() {
    if (!_hasShownImageDialog && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _loadUserImage() async {
    final viewModel = context.read<MeViewModel>();
    await viewModel.loadUserImage();

    if (viewModel.userImageUrl == null || viewModel.userImageUrl!.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Generate Studymate'),
                content: const Text('你還沒擁有Studymate，一起來創造吧'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      context.go('/generate');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
        );
      }
    } else {
      //_showLoadingDialog();
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final viewModel = context.watch<MeViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AuthenticationService>(
                context,
                listen: false,
              ).logOut();
            },
            icon: Icon(Icons.exit_to_app, color: scheme.primary),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/img/home_bg.jpg', fit: BoxFit.cover),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.13,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ❤️ 心情條 + 愛心
                Consumer<MoodViewModel>(
                  builder: (context, moodVM, _) {
                    final filledCount = moodVM.mood.clamp(0, 5); // 限制 0~5
                    final segmentWidth = 40.0;
                    final spacing = 8.0;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final isFilled = index < filledCount;
                        final isLastFilled = index == filledCount - 1;

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing / 2,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              //  條狀格（含漸層 + 圓角）
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child:
                                    isFilled
                                        ? ShaderMask(
                                          shaderCallback: (bounds) {
                                            final totalWidth =
                                                segmentWidth * filledCount +
                                                spacing * (filledCount - 1);
                                            return const LinearGradient(
                                              colors: [
                                                Color(0xFFFFC1CC),
                                                Color.fromARGB(
                                                  255,
                                                  220,
                                                  76,
                                                  81,
                                                ),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ).createShader(
                                              Rect.fromLTWH(
                                                -index *
                                                    (segmentWidth + spacing),
                                                0,
                                                totalWidth,
                                                10,
                                              ),
                                            );
                                          },
                                          blendMode: BlendMode.srcATop,
                                          child: Container(
                                            width: segmentWidth,
                                            height: 10,
                                            color: Colors.white,
                                          ),
                                        )
                                        : Container(
                                          width: segmentWidth,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                        ),
                              ),

                              if (isLastFilled)
                                Positioned(
                                  top: -29,
                                  child: FadeTransition(
                                    opacity: _opacityAnimation,
                                    child: ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Color.fromARGB(255, 220, 76, 81),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 36), // 留空間給疊上來的愛心
                // 💬 對話框
                FutureBuilder<String>(
                  future: _greetingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: scheme.error),
                      );
                    } else {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 對話框背景圖片（可自動變高）
                              Opacity(
                                opacity: 0.85,
                                child: Image.asset(
                                  'assets/img/dialog_box.png',
                                  width: 360,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              // 文字部分
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 320,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 24.0,
                                  ),
                                  child: Text(
                                    snapshot.data ?? 'No greeting found',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: scheme.onBackground,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),
                if (viewModel.userImageUrl == null)
                  const CircularProgressIndicator(),
              ],
            ),
          ),

          if (viewModel.userImageUrl != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: _AnimatedImageFromUrl(
                  url: viewModel.userImageUrl!,
                  onImageDisplayed: _hideLoadingDialog,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedImageFromUrl extends StatefulWidget {
  final String url;
  final VoidCallback onImageDisplayed;

  const _AnimatedImageFromUrl({
    super.key,
    required this.url,
    required this.onImageDisplayed,
  });

  @override
  State<_AnimatedImageFromUrl> createState() => _AnimatedImageFromUrlState();
}

class _AnimatedImageFromUrlState extends State<_AnimatedImageFromUrl> {
  int _currentFrame = 0;
  Timer? _timer;
  bool _imageShown = false;

  @override
  void initState() {
    super.initState();
    _startFrameLoop();

    final image = NetworkImage(widget.url);
    final stream = image.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener((_, __) {
        if (!_imageShown) {
          _imageShown = true;
          widget.onImageDisplayed();
        }
      }),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startFrameLoop() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentFrame = (_currentFrame + 1) % 4;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) {
      return const Text("圖片網址無效");
    }

    return SizedBox(
      width: 400,
      height: 400,
      child: ClipRect(
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              const double scale = 2.0;

              final dx = (_currentFrame % 2) * width / 2;
              final dy = (_currentFrame ~/ 2) * height / 2;

              return Transform(
                transform:
                    Matrix4.identity()
                      ..scale(scale, scale)
                      ..translate(-dx, -dy),
                child: Image.network(
                  widget.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('圖片載入失敗');
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
