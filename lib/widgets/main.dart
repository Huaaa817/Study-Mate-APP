// import 'package:flutter/material.dart';
// import 'circle_image_button.dart';
// import 'rounded_rect_button.dart';

// void main() {
//   runApp(const ButtonPreviewApp());
// }

// class ButtonPreviewApp extends StatelessWidget {
//   const ButtonPreviewApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Button Preview',
//       home: const ButtonPreviewPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class ButtonPreviewPage extends StatelessWidget {
//   const ButtonPreviewPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('按鈕預覽')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 圓形圖片按鈕
//             CircleImageButton(
//               imagePath: 'assets/img/meat1.jpg', // 你要先加一張圖片進 assets
//               size: 80,
//               onPressed: () {
//                 debugPrint('CircleImageButton clicked');
//               },
//             ),
//             const SizedBox(height: 32),
//             // 長方形按鈕
//             RoundedRectButton(
//               text: '點我開始',
//               onPressed: () {
//                 debugPrint('淺底深框線按鈕被點了');
//               },
//               // backgroundColor: const Color.fromARGB(255, 185, 202, 220),
//               // borderColor: const Color.fromARGB(255, 40, 136, 215),
//               // textColor: const Color.fromARGB(255, 45, 45, 52),
//             )

//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ColorSchemeDemoApp());
}

class ColorSchemeDemoApp extends StatelessWidget {
  const ColorSchemeDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFFC1526E), // 主要按鈕、圖示
        onPrimary: Colors.white, // 主要按鈕內文字
        primaryContainer: Color(0xFFFFD9E1), // 按鈕背景（例如圓形圖按鈕）
        onPrimaryContainer: Colors.black, // 按鈕背景文字

        secondary: Color(0xFFE68A9E), // 次要元件（例如邊框）
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFFFE4EC),
        onSecondaryContainer: Colors.black,

        background: Color(0xFFFFF5F8), // scaffold 背景
        onBackground: Colors.black,

        surface: Colors.white, // 卡片或面板
        onSurface: Colors.black,

        error: Colors.red,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.latoTextTheme(),
    );


    return MaterialApp(
      title: 'ColorScheme Demo',
      theme: theme,
      home: const ColorSchemePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ColorSchemePage extends StatelessWidget {
  const ColorSchemePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final Map<String, Color> colors = {
      'primary': scheme.primary,
      'onPrimary': scheme.onPrimary,
      'primaryContainer': scheme.primaryContainer,
      'onPrimaryContainer': scheme.onPrimaryContainer,
      'secondary': scheme.secondary,
      'onSecondary': scheme.onSecondary,
      'secondaryContainer': scheme.secondaryContainer,
      'onSecondaryContainer': scheme.onSecondaryContainer,
      'tertiary': scheme.tertiary,
      'onTertiary': scheme.onTertiary,
      'tertiaryContainer': scheme.tertiaryContainer,
      'onTertiaryContainer': scheme.onTertiaryContainer,
      'error': scheme.error,
      'onError': scheme.onError,
      'errorContainer': scheme.errorContainer,
      'onErrorContainer': scheme.onErrorContainer,
      'background': scheme.background,
      'onBackground': scheme.onBackground,
      'surface': scheme.surface,
      'onSurface': scheme.onSurface,
      'surfaceVariant': scheme.surfaceVariant,
      'onSurfaceVariant': scheme.onSurfaceVariant,
      'outline': scheme.outline,
      'inverseSurface': scheme.inverseSurface,
      'onInverseSurface': scheme.onInverseSurface,
      'inversePrimary': scheme.inversePrimary,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('ColorScheme 顏色展示')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: colors.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: entry.value,
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Text(entry.key),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
