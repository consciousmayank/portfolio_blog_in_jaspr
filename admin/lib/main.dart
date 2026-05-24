import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes/router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      title: 'MJ Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.editorial(),
      darkTheme: AppTheme.terminal(),
      themeMode: themeMode.themeMode,
      routerConfig: router,
    );
  }
}
