import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/services/navigation.dart';

enum AppTab { todo, studyset, home, chat, achievement }

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    final tabs = [
      AppTab.todo,
      AppTab.studyset,
      AppTab.home,
      AppTab.chat,
      AppTab.achievement,
    ];

    final currentIndex = tabs.indexWhere(
      (tab) => currentPath.contains('/${tab.name}'),
    );

    return BottomNavigationBar(
      currentIndex: currentIndex >= 0 ? currentIndex : 2, // 預設 Home
      onTap: (index) {
        GoRouter.of(context).go('/${tabs[index].name}');
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Todo'),
        BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'StudySet'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Achievement',
        ),
      ],
    );
  }
}
