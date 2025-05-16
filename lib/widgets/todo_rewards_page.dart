import 'package:flutter/material.dart';

class TodoRewardsPage extends StatelessWidget {
  const TodoRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('獎勵領取')),
      body: const Center(
        child: Text('恭喜完成任務！這是你的獎勵 🎉'),
      ),
    );
  }
}
