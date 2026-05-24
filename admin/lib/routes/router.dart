import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth.dart';
import '../screens/blog_editor_screen.dart';
import '../screens/blog_list_screen.dart';
import '../screens/experiments_screen.dart';
import '../screens/login_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shell_screen.dart';
import '../screens/skills_screen.dart';
import '../screens/timeline_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/blog',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      if (auth.loading) return null;
      final goingToLogin = state.matchedLocation == '/login';
      if (!auth.isAuthed && !goingToLogin) return '/login';
      if (auth.isAuthed && goingToLogin) return '/blog';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (ctx, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(path: '/blog', builder: (_, __) => const BlogListScreen()),
          GoRoute(
            path: '/blog/new',
            builder: (_, __) => const BlogEditorScreen(slug: null),
          ),
          GoRoute(
            path: '/blog/:slug',
            builder: (_, st) => BlogEditorScreen(slug: st.pathParameters['slug']),
          ),
          GoRoute(path: '/timeline', builder: (_, __) => const TimelineScreen()),
          GoRoute(path: '/skills', builder: (_, __) => const SkillsScreen()),
          GoRoute(path: '/experiments', builder: (_, __) => const ExperimentsScreen()),
          GoRoute(path: '/messages', builder: (_, __) => const MessagesScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _sub = _ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
