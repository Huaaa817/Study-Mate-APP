import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/view_models/me_wm.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_app/services/fetch_study_mate.dart';
import 'package:flutter_app/view_models/personality_vm.dart';
import 'dart:async';

class GeneratePage extends StatefulWidget {
  final MeViewModel viewModel;

  const GeneratePage({super.key, required this.viewModel});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  Color hairColor = Colors.brown;
  Color skinColor = Colors.orange.shade100;
  String hairLength = '長髮';
  String hairstyle = '捲髮';
  String personality = '開朗';

  Uint8List? _generatedImage;
  bool _isGenerating = false;

  final List<String> hairLengthOptions = ['長髮', '短髮', '中長'];
  final List<String> hairstyleOptions = ['捲髮', '直髮', '馬尾'];
  final List<String> personalityOptions = ['開朗', '冷靜', '友善', '有創意'];

  final Map<String, Color> namedColors = {
    '黑色': Color(0xFF000000),
    '白色': Color(0xFFFFFFFF),
    '紅色': Color(0xFFFF0000),
    'green': Color(0xFF00FF00),
    '藍色': Color(0xFF0000FF),
    '黃色': Color(0xFFFFFF00),
    '青色': Color(0xFF00FFFF),
    '洋紅色': Color(0xFFFF00FF),
    '灰色': Color(0xFF808080),
    '棕色': Color(0xFFA52A2A),
    '橙色': Color(0xFFFFA500),
    '淺橘膚色': Colors.orange.shade100,
  };

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  String _approximateColorName(Color color) {
    String closestName = '未知色';
    double minDistance = double.infinity;

    namedColors.forEach((name, namedColor) {
      final distance = _colorDistance(color, namedColor);
      if (distance < minDistance) {
        minDistance = distance;
        closestName = name;
      }
    });

    return closestName;
  }

  double _colorDistance(Color a, Color b) {
    return sqrt(
      pow(a.red - b.red, 2) +
          pow(a.green - b.green, 2) +
          pow(a.blue - b.blue, 2),
    );
  }

  void _pickColor(Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('選擇顏色'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: currentColor,
                onColorChanged: onColorChanged,
                showLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: [
              TextButton(
                child: const Text('完成'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _showGeneratingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const AlertDialog(
            title: Text("正在生成..."),
            content: SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
    );
  }

  Future<void> _runFlow() async {
    _showGeneratingDialog();
    try {
      final data = await fetchStudyMateImage(
        hairLength,
        _approximateColorName(hairColor),
        hairstyle,
        'hat',
        _approximateColorName(skinColor),
        personality,
        'calm',
        'friendly',
        'creative',
        'Add sunglasses',
      );

      String base64Str = data['imageBase64'] as String;
      if (base64Str.startsWith('data:image')) {
        final commaIndex = base64Str.indexOf(',');
        base64Str = base64Str.substring(commaIndex + 1);
      }
      final Uint8List imageBytes = base64Decode(base64Str);

      // 🟡 預設圖片為原圖
      Uint8List finalImageBytes = imageBytes;

      print('獲取照片成功，開始嘗試去背...');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      );
      request.headers['X-Api-Key'] = 'YOUR_API_KEY'; // 替換成你的 API Key
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
        finalImageBytes = result; // ✅ 用去背後圖片取代
        print('去背成功');
      } else {
        final errorMsg = await response.stream.bytesToString();
        print('去背失敗: $errorMsg');
      }

      Navigator.of(context).pop(); // 關閉 loading dialog

      setState(() => _generatedImage = finalImageBytes); // ✅ 顯示去背後圖片
      _showGeneratedImageDialog(finalImageBytes); // ✅ 用去背後圖片做預覽與儲存
    } catch (e) {
      Navigator.of(context).pop();
      print('發生錯誤: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('發生錯誤，請稍後再試')));
    }
  }

  void _showGeneratedImageDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text("生成結果"),
            content: Image.memory(imageBytes),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Regenerate"),
              ),
              TextButton(
                onPressed: () async {
                  final base64Image = base64Encode(imageBytes);
                  await widget.viewModel.saveUserImage(base64Image);

                  final userId =
                      widget.viewModel.me?.id ?? widget.viewModel.myId;
                  if (userId.isNotEmpty) {
                    final personalityVM = PersonalityViewModel();
                    await personalityVM.savePersonality(
                      userId: userId,
                      personality: personality,
                    );
                  }

                  await widget.viewModel.loadUserImage();
                  final fetchedImage = widget.viewModel.userImageUrl;

                  if (mounted && fetchedImage != null) {
                    final image = Image.network(fetchedImage);

                    final completer = Completer<void>();
                    final ImageStream stream = image.image.resolve(
                      const ImageConfiguration(),
                    );

                    late final ImageStreamListener listener;
                    listener = ImageStreamListener(
                      (ImageInfo _, bool __) {
                        completer.complete();
                        stream.removeListener(listener);
                      },
                      onError: (dynamic _, StackTrace? __) {
                        completer.completeError('Image load failed');
                        stream.removeListener(listener);
                      },
                    );

                    stream.addListener(listener);

                    try {
                      await completer.future; // 等圖片載入完成
                      if (mounted) {
                        Navigator.of(context).pop(); // 關閉對話框
                        context.go('/home', extra: fetchedImage);
                      }
                    } catch (e) {
                      if (mounted) {
                        Navigator.of(context).pop(); // 關閉對話框
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('圖片載入失敗，請稍後再試')),
                        );
                      }
                    }
                  }
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生成形象'),
        actions: [
          TextButton(
            onPressed: _runFlow,
            child: const Text('生成形象', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('髮色'),
              subtitle: Text(
                '${_colorToHex(hairColor)} / ${_approximateColorName(hairColor)}',
              ),
              trailing: CircleAvatar(backgroundColor: hairColor),
              onTap:
                  () => _pickColor(
                    hairColor,
                    (color) => setState(() => hairColor = color),
                  ),
            ),
            ListTile(
              title: const Text('膚色'),
              subtitle: Text(
                '${_colorToHex(skinColor)} / ${_approximateColorName(skinColor)}',
              ),
              trailing: CircleAvatar(backgroundColor: skinColor),
              onTap:
                  () => _pickColor(
                    skinColor,
                    (color) => setState(() => skinColor = color),
                  ),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '頭髮長度'),
              value: hairLength,
              items:
                  hairLengthOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (val) => setState(() => hairLength = val!),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '髮型'),
              value: hairstyle,
              items:
                  hairstyleOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (val) => setState(() => hairstyle = val!),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '個性'),
              value: personality,
              items:
                  personalityOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (val) => setState(() => personality = val!),
            ),
          ],
        ),
      ),
    );
  }
}
