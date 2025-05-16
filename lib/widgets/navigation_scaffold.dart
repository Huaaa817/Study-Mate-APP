import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';

class NavigationScaffold extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const NavigationScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
