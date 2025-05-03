import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:flutter_app/services/fetch_study_mate.dart';
import 'package:flutter_app/services/fetch_chat.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _processedImage;
  String? _greeting;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 取得問候語
      final greeting = await fetchGreeting("高冷");

      // 取得並處理圖片
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
      final base64Str = data['imageBase64'] as String;
      final Uint8List imageBytes = base64Decode(base64Str);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      );
      request.headers['X-Api-Key'] = 'Q8a1jbLGaGvaf77ZKq89PgUm'; // 請替換為你自己的 Key
      request.files.add(
        http.MultipartFile.fromBytes(
          'image_file',
          imageBytes,
          filename: 'from_flow.png',
        ),
      );
      request.fields['size'] = 'auto';

      final response = await request.send();

      if (response.statusCode == 200) {
        final Uint8List result = await response.stream.toBytes();
        final dir = await getApplicationDocumentsDirectory();
        final filePath = path.join(dir.path, 'processed_image.png');
        final file = File(filePath);
        await file.writeAsBytes(result);

        setState(() {
          _greeting = greeting;
          _processedImage = result;
          _isLoading = false;
        });
      } else {
        final errorMsg = await response.stream.bytesToString();
        setState(() {
          _error = '去背失敗（${response.statusCode}）: $errorMsg';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '發生錯誤: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_greeting != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _greeting!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_processedImage != null) Image.memory(_processedImage!),
                ],
              ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
