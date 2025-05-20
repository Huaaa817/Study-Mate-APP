import 'package:flutter/material.dart';
import 'package:flutter_app/repositories/user_id.dart';
import 'package:flutter_app/view_models/user_id_vm.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/fetch_study_mate.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final _formKey = GlobalKey<FormState>();
  String? _personality;
  String? _hairLength;
  String? _skinColor;

  bool _submitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _submitting = true);

    final viewModel = context.read<UserIdInputViewModel>();
    final userId = viewModel.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
      setState(() => _submitting = false);
      return;
    }

    try {
      // ✅ 更新 Firestore 個人資料
      await viewModel.updateUserProfile(
        personality: _personality!,
        hairLength: _hairLength!,
        skinColor: _skinColor!,
      );

      // ✅ 更新 ViewModel 狀態
      viewModel.setUserProfile(
        personality: _personality!,
        hairLength: _hairLength!,
        skinColor: _skinColor!,
      );

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
      //request.headers['X-Api-Key'] = 'YOUR_API_KEY';
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
      } else {
        final errorMsg = await response.stream.bytesToString();
        print('去背失敗: $errorMsg');
        final base64OriginalImage = data['imageBase64'] as String;
        await viewModel.saveUserImage(base64OriginalImage);
      }

      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Personality'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _personality = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Hair Length'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _hairLength = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Skin Color'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _skinColor = value,
              ),
              const SizedBox(height: 32),
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Save and Continue'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
