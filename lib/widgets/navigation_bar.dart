import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService(); // 訪問單例
    final currentIndex = [
      AppTab.todo,
      AppTab.studyset,
      AppTab.home,
      AppTab.chat,
      AppTab.achievement,
    ].indexWhere((tab) => navigationService.isCurrentTab(context, tab));

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        navigationService.goToTab(tab: AppTab.values[index]);
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: 'Todo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timer),
          label: 'StudySet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Achievement',
        ),
      ],
    );
  }
}