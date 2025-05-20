// import 'package:flutter/material.dart';
// import 'package:flutter_app/services/navigation.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import '/providers/study_duration_provider.dart';
// import 'package:flutter_app/yuhung_try/try_flow_yuhung.dart';

// final theme = ThemeData(
//   useMaterial3: true,
//   colorScheme: ColorScheme.fromSeed(
//     brightness: Brightness.light,
//     seedColor: const Color.fromARGB(255, 193, 82, 110),
//   ),
//   textTheme: GoogleFonts.latoTextTheme(),
// );

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); //初始化綁定
//   await Firebase.initializeApp(
//     // 正確使用 await
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   //runApp(MaterialApp(home: AnimatedImageFromFlow()));
//   runApp(
//     MultiProvider(
//       providers: [
//         Provider<NavigationService>(create: (_) => NavigationService()),
//         ChangeNotifierProvider<StudyDurationProvider>(
//           create: (_) => StudyDurationProvider(),
//         ),
//       ],
//       child: const App(),
//     ),
//   );
// }

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       theme: theme,
//       routerConfig: routerConfig,
//       restorationScopeId: 'app',
//     );
//   }
// }import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '/providers/study_duration_provider.dart';
import 'package:flutter_app/view_models/user_id_vm.dart'; // ← 加這個

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 193, 82, 110),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StudyDurationProvider>(
          create: (_) => StudyDurationProvider(),
        ),
        ChangeNotifierProvider<UserIdInputViewModel>(
          // ← ✅ 加上這段
          create: (_) => UserIdInputViewModel(),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: theme,
      routerConfig: routerConfig,
      restorationScopeId: 'app',
    );
  }
}
