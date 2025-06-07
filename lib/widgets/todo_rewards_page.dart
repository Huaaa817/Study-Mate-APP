import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/services/fetch_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_app/view_models/me_wm.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class TodoRewardsPage extends StatefulWidget {
  const TodoRewardsPage({super.key});

  @override
  State<TodoRewardsPage> createState() => _TodoRewardsPageState();
}

class _TodoRewardsPageState extends State<TodoRewardsPage> {
  bool _loading = true;
  Widget? _imageWidget;

  final List<String> _sceneDescriptions = [
    "A quiet university courtyard in the early morning...",
    "A cozy rooftop under a starry night sky...",
    "A riverside path beneath blooming cherry blossom trees...",
    "An indoor Japanese-style study room with tatami flooring...",
    "A peaceful grassy field under soft golden sunlight...",
  ];

  @override
  void initState() {
    super.initState();
    _generateRewardImage();
  }

  Future<void> _generateRewardImage() async {
    try {
      final scene = (_sceneDescriptions..shuffle()).first;
      final userId = Provider.of<MeViewModel>(context, listen: false).myId;

      final imageUrl = await fetchBackground(description: scene);

      // 轉 base64 ➝ bytes
      final base64Data = imageUrl.split(',').last;
      final Uint8List bytes = base64Decode(base64Data);

      // 上傳至 Firebase Storage
      final fileName = 'reward_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = firebase_storage.FirebaseStorage.instance.ref().child(
        'apps/study_mate/users/$userId/backgrounds/$fileName',
      );

      final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/png',
      );
      await ref.putData(bytes, metadata);

      final downloadUrl = await ref.getDownloadURL();

      // 等圖片真的可用
      final downloadedBytes = await _waitUntilImageAvailable(downloadUrl);

      // 儲存 Firestore metadata
      final backgroundsRef = FirebaseFirestore.instance
          .collection('apps/study_mate/users')
          .doc(userId)
          .collection('backgrounds');

      await backgroundsRef.add({
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': downloadUrl,
        'description': scene,
      });

      final imageWidget = Image.memory(downloadedBytes, fit: BoxFit.cover);

      if (mounted) {
        setState(() {
          _imageWidget = imageWidget;
          _loading = false;
        });
      }
    } catch (e) {
      print('❌ Failed to generate image: $e');
      if (mounted) {
        setState(() {
          _imageWidget = const Icon(Icons.error, size: 80, color: Colors.red);
          _loading = false;
        });
      }
    }
  }

  Future<Uint8List> _waitUntilImageAvailable(String url) async {
    const maxTries = 10;
    const delay = Duration(seconds: 1);
    int attempt = 0;

    while (attempt < maxTries) {
      try {
        final res = await http.get(Uri.parse(url));
        if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
          return res.bodyBytes;
        }
      } catch (_) {}
      await Future.delayed(delay);
      attempt++;
    }

    throw Exception('Image not ready after $maxTries retries');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('獎勵領取')),
      body: Center(
        child:
            _loading
                ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('獎勵配送中，請稍後...'),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 300, child: _imageWidget ?? Container()),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => GoRouter.of(context).go('/todo'),
                      icon: const Icon(Icons.check),
                      label: const Text('收下'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
