import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/widgets/todo_page.dart';
import 'package:flutter_app/widgets/study_page.dart';
import 'package:flutter_app/widgets/study_set_page.dart';
import 'package:flutter_app/widgets/home_page.dart';
import 'package:flutter_app/widgets/chat_page.dart';
import 'package:flutter_app/widgets/feed_page.dart';
import 'package:flutter_app/widgets/achievement_page.dart';

final routerConfig = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/todo',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: TodoPage(),
      ),
    ),
    GoRoute(
      path: '/studyset',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: StudySetPage(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: HomePage(),
      ),
    ),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: ChatPage(),
      ),
    ),
    GoRoute(
      path: '/achievement',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: AchievementPage(),
      ),
    ),
    GoRoute(
      path: '/study',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: StudyPage(),
      ),
    ),
    GoRoute(
      path: '/feed',
      pageBuilder: (context, state) => const NoTransitionPage<void>(
        child: FeedPage(),
      ),
    ),
  ],
  initialLocation: '/home', // 預設顯示 HomePage
  debugLogDiagnostics: true,
  redirect: (context, state) {
    if (state.uri.path == '/') {
      return '/home'; // 根路徑重定向到 /home
    }
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri.path}'),
    ),
  ),
);

enum AppTab { todo, studyset, home, chat, achievement }

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  void goToTab({required AppTab tab}) {
    _router.go('/${tab.name}');
  }

  bool isCurrentTab(BuildContext context, AppTab tab) {
    return _currentPath(context) == '/${tab.name}';
  }
}