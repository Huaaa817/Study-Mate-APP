import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/widgets/auth_page.dart';
import 'package:flutter_app/services/authentication.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/widgets/navigation_scaffold.dart';
import 'package:flutter_app/widgets/home_page.dart';
import 'package:flutter_app/widgets/chat_page.dart';
import 'package:flutter_app/widgets/study_page.dart';
import 'package:flutter_app/widgets/study_set_page.dart';
import 'package:flutter_app/widgets/todo_page.dart';
import 'package:flutter_app/widgets/todo_rewards_page.dart';
import 'package:flutter_app/widgets/achievement_page.dart';
import 'package:flutter_app/widgets/feed_page.dart';
import 'package:flutter_app/widgets/generate_page.dart';

GoRouter routerConfig(bool isLoggedIn) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/auth',
        pageBuilder:
            (context, state) => const NoTransitionPage(child: AuthPage()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: NavigationScaffold(
                currentPath: state.uri.path,
                child: const HomePage(),
              ),
            ),
      ),
      GoRoute(
        path: '/todo',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: NavigationScaffold(
                currentPath: state.uri.path,
                child: const TodoPage(),
              ),
            ),
      ),
      GoRoute(
        path: '/todo_rewards',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: NavigationScaffold(
                currentPath: state.uri.path,
                child: const TodoRewardsPage(),
              ),
            ),
      ),
      GoRoute(
        path: '/studyset',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: NavigationScaffold(
                currentPath: state.uri.path,
                child: const StudySetPage(),
              ),
            ),
      ),
      GoRoute(
        path: '/study',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: NavigationScaffold(
                currentPath: state.uri.path,
                child: const StudyPage(),
              ),
            ),
      ),
      GoRoute(
        path: '/feed',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: NavigationScaffold(
                currentPath: state.uri.path,
                child: const FeedPage(),
              ),
            ),
      ),
      GoRoute(
        path: '/chat',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: NavigationScaffold(
                currentPath: state.uri.path,
                child: ChatPage(userPersonality: '可愛'),
              ),
            ),
      ),
      GoRoute(
        path: '/achievement',
        pageBuilder:
            (context, state) => NoTransitionPage(
              child: NavigationScaffold(
                currentPath: state.uri.path,
                child: const AchievementPage(),
              ),
            ),
      ),
      GoRoute(
        path: '/generate',
        pageBuilder:
            (context, state) => const NoTransitionPage(child: GeneratePage()),
      ),
    ],
    initialLocation: isLoggedIn ? '/home' : '/auth',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final location = state.uri.toString(); // ✅ 安全替代 subloc
      final loggingIn = location == '/auth';

      if (!isLoggedIn && !loggingIn) return '/auth';
      if (isLoggedIn && loggingIn) return '/home';
      return null;
    },
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Page not found: ${state.uri.path}')),
        ),
  );
}
