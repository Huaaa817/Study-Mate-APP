import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key}); // const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home Page')),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}