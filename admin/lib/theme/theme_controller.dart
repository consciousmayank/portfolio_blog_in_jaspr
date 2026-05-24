import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app_theme.dart';

const _themeKey = 'admin_theme';

/// Persisted theme preference. `system` follows OS dark mode.
class ThemeController extends StateNotifier<AdminThemeMode> {
  ThemeController(this._ref) : super(AdminThemeMode.system) {
    _load();
  }
  final Ref _ref;

  FlutterSecureStorage get _storage => _ref.read(themeStorageProvider);

  Future<void> _load() async {
    try {
      final id = await _storage.read(key: _themeKey);
      state = AdminThemeModeX.parse(id);
    } catch (_) {/* defaults to system */}
  }

  Future<void> setMode(AdminThemeMode mode) async {
    state = mode;
    await _storage.write(key: _themeKey, value: mode.id);
  }
}

/// We share one FlutterSecureStorage with the auth module — same package
/// initialises a single Keychain group, no contention.
final themeStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final themeControllerProvider =
    StateNotifierProvider<ThemeController, AdminThemeMode>(
  (ref) => ThemeController(ref),
);
