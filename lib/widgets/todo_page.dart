import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: const Center(child: Text('Todo Page')),
      bottomNavigationBar: AppBottomNavigationBar(),
    );
  }
}