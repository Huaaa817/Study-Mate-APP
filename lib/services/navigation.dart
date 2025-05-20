import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/widgets/todo_page.dart';
import 'package:flutter_app/widgets/study_page.dart';
import 'package:flutter_app/widgets/study_set_page.dart';
import 'package:flutter_app/widgets/home_page.dart';
import 'package:flutter_app/widgets/chat_page.dart';
import 'package:flutter_app/widgets/feed_page.dart';
import 'package:flutter_app/widgets/achievement_page.dart';
import 'package:flutter_app/widgets/todo_rewards_page.dart';
import 'package:flutter_app/widgets/user_id_input_page.dart'; // 新增
import 'package:flutter_app/widgets/generate_page.dart'; // 新增
import 'package:flutter_app/widgets/navigation_scaffold.dart';

final routerConfig = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/user_id_input',
      pageBuilder:
          (context, state) =>
              const NoTransitionPage<void>(child: UserIdInputPage()),
    ),
    GoRoute(
      path: '/generate',
      pageBuilder:
          (context, state) =>
              const NoTransitionPage<void>(child: GeneratePage()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            child: NavigationScaffold(
              currentPath: state.uri.path,
              child: const HomePage(),
            ),
          ),
    ),
    GoRoute(
      path: '/todo',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            child: NavigationScaffold(
              currentPath: state.uri.path,
              child: const TodoPage(),
            ),
          ),
    ),
    GoRoute(
      path: '/todo_rewards',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            child: NavigationScaffold(
              currentPath: state.uri.path,
              child: const TodoRewardsPage(),
            ),
          ),
    ),
    GoRoute(
      path: '/studyset',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            child: NavigationScaffold(
              currentPath: state.uri.path,
              child: const StudySetPage(),
            ),
          ),
    ),
    GoRoute(
      path: '/study',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            child: NavigationScaffold(
              currentPath: state.uri.path,
              child: const StudyPage(),
            ),
          ),
    ),
    GoRoute(
      path: '/feed',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            child: NavigationScaffold(
              currentPath: state.uri.path,
              child: const FeedPage(),
            ),
          ),
    ),
    GoRoute(
      path: '/chat',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            child: NavigationScaffold(
              currentPath: state.uri.path,
              child: ChatPage(userPersonality: '可愛'),
            ),
          ),
    ),
    GoRoute(
      path: '/achievement',
      pageBuilder:
          (context, state) => NoTransitionPage<void>(
            child: NavigationScaffold(
              currentPath: state.uri.path,
              child: const AchievementPage(),
            ),
          ),
    ),
  ],
  initialLocation: '/user_id_input', // 修改初始頁面
  debugLogDiagnostics: true,
  redirect: (context, state) {
    if (state.uri.path == '/') {
      return '/user_id_input';
    }
    return null;
  },
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.uri.path}')),
      ),
);
