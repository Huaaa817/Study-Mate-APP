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
import 'package:flutter_app/widgets/swipe_card.dart';

class GeneratePage extends StatefulWidget {
  final MeViewModel viewModel;

  const GeneratePage({super.key, required this.viewModel});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  Color hairColor = Colors.brown;
  Color skinColor = Colors.orange.shade100;
  String hairLength = 'Long Hair';
  String hairstyle = 'Curly';
  String personality = 'Cheerful';

  Uint8List? _generatedImage;
  bool _isGenerating = false;
  final ScrollController _scrollController = ScrollController();
  Color appBarColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    print("Scroll offset: ${_scrollController.offset}");
    final newColor =
        _scrollController.offset > 10
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent;

    if (newColor != appBarColor) {
      setState(() {
        appBarColor = newColor;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<String> hairLengthOptions = [
    'Long Hair',
    'Short Hair',
    'Medium Length',
  ];
  final List<String> hairstyleOptions = [
    'Curly',
    'Straight',
    'Ponytail',
    'Braided',
    'Twin Tails',
    'Bob Cut',
    'Long Wavy',
    'Bun',
    'Side Sweep',
    'Messy',
  ];
  final List<String> personalityOptions = [
    'Cheerful',
    'Shy',
    'Tsundere',
    'Mysterious',
    'Clumsy',
    'Elegant',
    'Rebellious',
    'Gentle',
    'Mischievous',
    'Romantic',
  ];
  final Map<String, Color> namedColors_hair = {
    'black': Color(0xFF000000),
    'white': Color(0xFFFFFFFF),
    'red': Color(0xFFFF0000),
    'green': Color(0xFF00FF00),
    'blue': Color(0xFF0000FF),
    'yellow': Color(0xFFFFFF00),
    'cyan': Color(0xFF00FFFF),
    'magenta': Color(0xFFFF00FF),
    'gray': Color(0xFF808080),
    'darkGray': Color(0xFFA9A9A9),
    'lightGray': Color(0xFFD3D3D3),
    'brown': Color(0xFFA52A2A),
    'darkBrown': Color(0xFF5C4033),
    'chestnut': Color(0xFF964B00),
    'lightBrown': Color(0xFFB5651D),
    'ashBrown': Color(0xFF8B6D5C),
    'goldenBrown': Color(0xFF996515),
    'auburn': Color(0xFF7C0A02),
    'burgundy': Color(0xFF800020),
    'mahogany': Color(0xFFC04000),
    'copper': Color(0xFFB87333),
    'platinum': Color(0xFFE5E4E2),
    'silver': Color(0xFFC0C0C0),
    'roseGold': Color(0xFFB76E79),
    'peachBlonde': Color(0xFFFFDAB9),
    'honeyBlonde': Color(0xFFF0C05A),
    'strawberryBlonde': Color(0xFFFCB0A9),
    'ashBlonde': Color(0xFFE6D8AD),
    'goldenBlonde': Color(0xFFFFDF00),
    'dirtyBlonde': Color(0xFFB3A369),
    'lightBlonde': Color(0xFFFFF1B5),
    'darkBlonde': Color(0xFFBEAC74),
    'silverBlue': Color(0xFFB0C4DE),
    'lavender': Color(0xFFE6E6FA),
    'lilac': Color(0xFFC8A2C8),
    'pink': Color(0xFFFFC0CB),
    'rosePink': Color(0xFFFB607F),
    'purple': Color(0xFF800080),
    'violet': Color(0xFF8F00FF),
    'indigo': Color(0xFF4B0082),
    'navy': Color(0xFF000080),
    'teal': Color(0xFF008080),
    'turquoise': Color(0xFF40E0D0),
    'skyBlue': Color(0xFF87CEEB),
    'lightBlue': Color(0xFFADD8E6),
    'darkBlue': Color(0xFF00008B),
    'mint': Color(0xFF98FF98),
    'peach': Color(0xFFFFE5B4),
    'coral': Color(0xFFFF7F50),
    'orange': Color(0xFFFFA500),
    'beige': Color(0xFFF5F5DC),
    'ivory': Color(0xFFFFFFF0),
    'khaki': Color(0xFFF0E68C),
  };

  final Map<String, Color> namedColors_skin = {
    // Added skin tones
    'pale skin': Color(0xFFFFFBF0),
    'fair skin': Color(0xFFFFEAD3),
    'light peach skin': Color(0xFFFFDBAC),
    'golden skin': Color(0xFFF1C27D),
    'tan skin': Color(0xFFEDC393),
    'bronzed skin': Color(0xFFAD6E3F), // 👈 新增古銅色
    'warm brown skin': Color(0xFFB68644),
    'deep brown skin': Color(0xFF8D5524),
    'dark skin': Color(0xFF3B2F2F),
    'ebony skin': Color(0xFF14100D),
  };

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  String _approximateColorName_hair(Color color) {
    String closestName = '未知色';
    double minDistance = double.infinity;

    namedColors_hair.forEach((name, namedColor) {
      final distance = _colorDistance(color, namedColor);
      if (distance < minDistance) {
        minDistance = distance;
        closestName = name;
      }
    });

    return closestName;
  }

  String _approximateColorName_skin(Color color) {
    String closestName = '未知色';
    double minDistance = double.infinity;

    namedColors_skin.forEach((name, namedColor) {
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

  void _pickColor_ton(Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('選擇膚色'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: currentColor,
                onColorChanged: onColorChanged,
                availableColors: const [
                  Color(0xFFFFFBF0), // pale skin
                  Color(0xFFFFEAD3), // fair skin
                  Color(0xFFFFDBAC), // light peach skin
                  Color(0xFFF1C27D), // golden skin
                  Color(0xFFEDC393), // tan skin
                  Color(0xFFAD6E3F), // bronzed skin
                  Color(0xFFB68644), // warm brown skin
                  Color(0xFF8D5524), // deep brown skin
                  Color(0xFF3B2F2F), // dark skin
                  Color(0xFF14100D), // ebony skin
                ],
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
    Timer? timer; // ✅ 外部先宣告成 nullable

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        int currentFrame = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            timer ??= Timer.periodic(const Duration(milliseconds: 300), (_) {
              setState(() {
                currentFrame = (currentFrame + 1) % 4;
              });
            });

            return AlertDialog(
              title: const Text("正在生成..."),
              content: SizedBox(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/img/gift${currentFrame + 1}.png',
                      height: 60,
                    ),
                    const SizedBox(height: 12),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      timer?.cancel(); // ✅ 關閉 Dialog 後釋放 Timer
    });
  }

  Future<void> _runFlow() async {
    _showGeneratingDialog();
    try {
      final data = await fetchStudyMateImage(
        hairLength,
        _approximateColorName_hair(hairColor),
        hairstyle,
        'hat',
        _approximateColorName_skin(skinColor),
        'smileFeling',
        'calm',
        personality,
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
      request.headers['X-Api-Key'] = '';// pUu4KGwYyRf9PMBaFH4WSdTZ'; // 替換成你的 API Key
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
        final Uint8List result = await response.stream.toBytes();
        setState(() {
          finalImageBytes = result;
        }); // ✅ 用去背後圖片取代
        print('去背成功');
      } else {
        final errorMsg = await response.stream.bytesToString();
        print('去背失敗: $errorMsg');
      }
      // ✅ 在這裡比較原圖與去背後圖的大小
      print('原圖大小: ${imageBytes.length}');
      print('去背圖大小: ${finalImageBytes.length}');

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
    print("background color:");
    print(appBarColor);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        centerTitle: true,
        title: const Text('generate your studymate'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                ),
                Expanded(child: const SwipeCard()),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),

            ListTile(
              title: const Text('髮色'),
              subtitle: Text(
                '${_colorToHex(hairColor)} / ${_approximateColorName_hair(hairColor)}',
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
                '${_colorToHex(skinColor)} / ${_approximateColorName_skin(skinColor)}',
              ),
              trailing: CircleAvatar(backgroundColor: skinColor),
              onTap:
                  () => _pickColor_ton(
                    skinColor,
                    (color) => setState(() => skinColor = color),
                  ),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '髮長'),
              value: hairLength,
              onChanged: (value) => setState(() => hairLength = value!),
              items:
                  hairLengthOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '髮型'),
              value: hairstyle,
              onChanged: (val) => setState(() => hairstyle = val!),
              items:
                  hairstyleOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '個性'),
              value: personality,
              onChanged: (val) => setState(() => personality = val!),
              items:
                  personalityOptions
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
            ),

            const SizedBox(height: 24),

            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _runFlow,
                  iconSize: 40,
                  padding: EdgeInsets.zero,
                  icon: ClipOval(
                    child: Image.asset(
                      'assets/generate.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
