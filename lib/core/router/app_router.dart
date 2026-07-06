import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/chats/presentation/pages/chats_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/launch/presentation/pages/launch_page.dart';
import '../../features/launch/presentation/pages/permissions_page.dart';
import '../../features/me/presentation/pages/me_page.dart';
import '../../features/post/presentation/pages/post_page.dart';
import '../../features/squads/presentation/pages/squads_page.dart';
import '../constants/app_strings.dart';

part 'app_router.g.dart';

abstract class AppRoutes {
  static const launch = '/launch';
  static const permissions = '/permissions';
  static const discover = '/discover';
  static const squads = '/squads';
  static const post = '/post';
  static const chats = '/chats';
  static const me = '/me';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.launch,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.launch,
        builder: (context, state) => const LaunchPage(),
      ),
      GoRoute(
        path: AppRoutes.permissions,
        builder: (context, state) => const PermissionsPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.squads,
                builder: (context, state) => const SquadsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.post,
                builder: (context, state) => const PostPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chats,
                builder: (context, state) => const ChatsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.me,
                builder: (context, state) => const _MeRoute(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
}

/// Bottom navigation shell wrapping all main tabs.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: AppStrings.navDiscover,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: AppStrings.navSquads,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: AppStrings.navPost,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: AppStrings.navChats,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.navMe,
          ),
        ],
      ),
    );
  }
}

/// Renders [MePage] when authenticated, [LoginPage] otherwise.
/// The bottom navigation bar (from [MainShell]) remains visible in both cases.
class _MeRoute extends ConsumerWidget {
  const _MeRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return switch (authState) {
      AuthAuthenticated() => const MePage(),
      _ => const LoginPage(),
    };
  }
}
