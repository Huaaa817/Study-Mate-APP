import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/navigation_bar.dart';
import '/services/fetch_chat.dart'; // 引入fetch_chat.dart

class HomePage extends StatelessWidget {
  const HomePage({super.key}); // const

  Future<String> getGreeting() async {
    // 這裡的性格可以根據需要動態傳入
    return await fetchGreeting("高冷");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: FutureBuilder<String>(
        future: getGreeting(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return Center(
              child: Text(
                snapshot.data ?? 'No greeting found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
