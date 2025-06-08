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
//       restorationScopeId: 'app',S
//     );
//   }
// }import 'package:flutter/material.dart';// main.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// import 'package:flutter_app/services/authentication.dart';
// import 'package:flutter_app/services/navigation.dart';
// import '/providers/study_duration_provider.dart';
// import 'package:flutter_app/view_models/me_wm.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => StudyDurationProvider()),
//         Provider(create: (_) => AuthenticationService()),
//         //Provider(create: (_) => NavigationService()),
//       ],
//       child: const App(),
//     ),
//   );
// }

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthenticationService>(
//       context,
//       listen: false,
//     );

//     return StreamBuilder<String?>(
//       stream: authService.userIdStream(),
//       builder: (context, snapshot) {
//         final userId = snapshot.data;
//         final isLoggedIn = userId != null;

//         return MultiProvider(
//           providers: [
//             if (isLoggedIn)
//               ChangeNotifierProvider(create: (_) => MeViewModel(userId!)),
//           ],
//           child: MaterialApp.router(
//             theme: ThemeData.light(), // 你也可以換成自定義 theme
//             routerConfig: routerConfig(isLoggedIn),
//             restorationScopeId: 'app',
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'firebase_options.dart';
// import 'services/authentication.dart';
// import 'services/navigation.dart';
// import 'providers/study_duration_provider.dart';
// import 'view_models/me_wm.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(const RootApp());
// }

// class RootApp extends StatelessWidget {
//   const RootApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => StudyDurationProvider()),
//         Provider(create: (_) => AuthenticationService()),
//       ],
//       child: const App(),
//     );
//   }
// }

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = Provider.of<AuthenticationService>(
//       context,
//       listen: false,
//     );

//     return StreamBuilder<String?>(
//       stream: authService.userIdStream(),
//       builder: (context, snapshot) {
//         final userId = snapshot.data;
//         final isLoggedIn = userId != null;

//         return MultiProvider(
//           providers: [
//             if (isLoggedIn)
//               ChangeNotifierProvider(create: (_) => MeViewModel(userId!)),
//           ],
//           child: MaterialApp.router(
//             restorationScopeId: 'app',
//             theme: ThemeData.light(), // 或自訂 ThemeData
//             routerConfig: routerConfig(isLoggedIn),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import '/providers/study_duration_provider.dart';
import '/providers/background_provider.dart';
import 'view_models/todo_list_vm.dart';
import 'repositories/todo_list_repo.dart';
import 'view_models/study_vm.dart';
import 'repositories/study_repo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/authentication.dart';
import 'services/navigation.dart';
import 'view_models/me_wm.dart';
import 'view_models/mood_vm.dart';
import 'view_models/feed_vm.dart';
import 'repositories/feed_repo.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFC1526E), // 主要按鈕、圖示
    onPrimary: Colors.white, // 主要按鈕內文字
    primaryContainer: Color.fromARGB(255, 243, 189, 200), // 按鈕背景（例如圓形圖按鈕）
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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudyDurationProvider()),
        Provider(create: (_) => AuthenticationService()),
        ChangeNotifierProvider(create: (_) => BackgroundViewModel()),
      ],
      child: const App(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthenticationService>(
      context,
      listen: false,
    );

    return StreamBuilder<String?>(
      stream: authService.userIdStream(),
      builder: (context, snapshot) {
        final userId = snapshot.data;
        final isLoggedIn = userId != null;

        if (isLoggedIn) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MeViewModel(userId!)),
              ChangeNotifierProvider(
                create: (_) => TodoListViewModel(TodoListRepository(), userId!),
              ),
              ChangeNotifierProvider(
                create: (_) => MoodViewModel(userId!),
              ),ChangeNotifierProvider(
                create: (_) => StudyViewModel(StudyRepository(), userId!),
              ),
              ChangeNotifierProvider(
                create: (_) => FeedViewModel(FeedRepository(),userId!), // 可改為 FirebaseAuth.user.uid
              ),
            ],
            child: MaterialApp.router(
              restorationScopeId: 'app',
              theme: theme,
              routerConfig: routerConfig(true),
            ),
          );
        } else {
          return MaterialApp.router(
            restorationScopeId: 'app',
            theme: theme,
            routerConfig: routerConfig(false),
          );
        }
      },
    );
  }
}
