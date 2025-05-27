import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/view_models/me_wm.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/services/fetch_study_mate.dart';

class GeneratePage extends StatelessWidget {
  final MeViewModel viewModel;
  const GeneratePage({super.key, required this.viewModel});

  Future<void> _runFlow(BuildContext context) async {
    try {
      // ✅ 生成圖像
      final data = await fetchStudyMateImage(
        'long',
        'black',
        'wavy',
        'hat',
        'light',
        'happy',
        'calm',
        'friendly',
        'creative',
        'Add sunglasses',
      );

      final imageBytes = base64Decode(data['imageBase64']);
      print('獲取照片成功');

      // ✅ 嘗試去背
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      );
      // request.headers['X-Api-Key'] = 'YOUR_API_KEY';
      request.files.add(
        http.MultipartFile.fromBytes(
          'image_file',
          imageBytes,
          filename: 'gen.png',
        ),
      );
      request.fields['size'] = 'auto';

      final response = await request.send();

      if (response.statusCode == 200) {
        final result = await response.stream.toBytes();
        final base64Image = base64Encode(result);
        await viewModel.saveUserImage(base64Image);
        print('去背成功並已儲存');
      } else {
        final errorMsg = await response.stream.bytesToString();
        print('去背失敗: $errorMsg');
        final base64OriginalImage = data['imageBase64'] as String;
        await viewModel.saveUserImage(base64OriginalImage);
        print('儲存原始照片');
      }

      // ✅ 跳轉到 /home
      context.go('/home');
    } catch (e) {
      print('發生錯誤: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('發生錯誤，請稍後再試')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _runFlow(context);
          },
          child: const Text('生成並前往首頁'),
        ),
      ),
    );
  }
}
