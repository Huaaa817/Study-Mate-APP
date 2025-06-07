import 'package:flutter/material.dart';
import 'package:flutter_app/services/fetch_chat.dart';
import 'package:flutter_app/view_models/me_wm.dart';
import 'package:flutter_app/services/authentication.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String>? _greetingFuture;
  bool _hasShownImageDialog = false;

  @override
  void initState() {
    super.initState();
    _greetingFuture = getGreeting();
    _checkDialogShownThenLoadImage();
  }

  Future<String> getGreeting() async {
    const personality = "可愛";
    return await fetchGreeting(personality);
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
                title: const Text('No Image Found'),
                content: const Text('Go to generate'),
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
      _showLoadingDialog();
    }
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          height: 55, // 可以依實際需要調整高度
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Center(
                            child: Text(
                              snapshot.data ?? 'No greeting found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: scheme.onBackground,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
