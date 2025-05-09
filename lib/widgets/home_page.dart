import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '/services/fetch_chat.dart';
import 'package:flutter_app/services/fetch_study_mate.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _processedImage;
  Future<String>? _greetingFuture;

  @override
  void initState() {
    super.initState();
    _greetingFuture = getGreeting();
    _processImageFromFlow();
  }

  Future<String> getGreeting() async {
    // 性格可以根據需要動態傳入
    return await fetchGreeting("可愛");
  }

  Future<void> _processImageFromFlow() async {
    try {
      print('1. 呼叫 Flow 獲取圖片...');
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

      print('2. 圖片獲取成功，開始去背...');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      );
      request.headers['X-Api-Key'] = 'Q8a1jbLGaGvaf77ZKq89PgUm'; // 自己的 Key
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
        print('3. 去背成功，儲存圖片...');

        final dir = await getApplicationDocumentsDirectory();
        final filePath = path.join(dir.path, 'processed_image.png');
        final file = File(filePath);
        await file.writeAsBytes(result);

        print('4. 圖片已儲存至: $filePath');

        setState(() {
          _processedImage = result;
        });
      } else {
        final errorMsg = await response.stream.bytesToString();
        print('去背失敗（${response.statusCode}）: $errorMsg');
      }
    } catch (e) {
      print('處理過程發生錯誤: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Home')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<String>(
            future: _greetingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator()); // ✅
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    snapshot.data ?? 'No greeting found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 20),
          _processedImage == null
              ? const CircularProgressIndicator()
              : Image.memory(_processedImage!),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
