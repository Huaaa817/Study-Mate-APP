import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key}); // const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievement')),
      body: const Center(child: Text('Achievement Page')),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}