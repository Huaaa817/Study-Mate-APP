import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/view_models/me_wm.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_app/services/fetch_study_mate.dart';
import 'package:flutter_app/view_models/personality_vm.dart';

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

  Future<void> _runFlow(BuildContext context) async {
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

      final imageBytes = base64Decode(data['imageBase64']);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      );
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
        await widget.viewModel.saveUserImage(base64Image);
      } else {
        final base64OriginalImage = data['imageBase64'] as String;
        await widget.viewModel.saveUserImage(base64OriginalImage);
      }
      // 取 userId
      final userId = widget.viewModel.me?.id ?? widget.viewModel.myId;

      if (userId.isNotEmpty) {
        final personalityVM = PersonalityViewModel();
        await personalityVM.savePersonality(
          userId: userId,
          personality: personality,
        );
      }

      context.go('/home');
    } catch (e) {
      print('發生錯誤: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('發生錯誤，請稍後再試')));
    }
  }

  @override
  Widget build(BuildContext context) {
    print("髮色: ${_approximateColorName(hairColor)}");
    print("膚色: ${_approximateColorName(skinColor)}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('生成形象'),
        actions: [
          TextButton(
            onPressed: () => _runFlow(context),
            child: const Text(
              '生成並前往首頁',
              style: TextStyle(color: Colors.black12),
            ),
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
                  () => _pickColor(hairColor, (color) {
                    setState(() => hairColor = color);
                  }),
            ),
            ListTile(
              title: const Text('膚色'),
              subtitle: Text(
                '${_colorToHex(skinColor)} / ${_approximateColorName(skinColor)}',
              ),
              trailing: CircleAvatar(backgroundColor: skinColor),
              onTap:
                  () => _pickColor(skinColor, (color) {
                    setState(() => skinColor = color);
                  }),
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
