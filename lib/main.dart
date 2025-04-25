import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 193, 82, 110),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Provide NavigationService
        Provider<NavigationService>(create: (_) => NavigationService()),
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
      // Allow the Navigator built by the MaterialApp to restore the navigation stack when app restarts
      restorationScopeId: 'app',
    );
  }
}
