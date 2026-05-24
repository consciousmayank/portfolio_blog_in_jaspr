import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';

const _tokenKey = 'jwt_token';
const _baseUrlKey = 'api_base_url';

final apiBaseUrlProvider = StateProvider<String>((ref) {
  // Default for local dev. On the web build, this is configurable from Settings.
  return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
});

final _storageProvider = Provider<FlutterSecureStorage>((ref) {
  // localStorage backing on web is acceptable for an admin tool — documented caveat.
  return const FlutterSecureStorage();
});

class AuthState {
  const AuthState({this.token, this.loading = false});
  final String? token;
  final bool loading;
  bool get isAuthed => token != null;

  AuthState copy({String? token, bool? loading, bool clearToken = false}) =>
      AuthState(
        token: clearToken ? null : (token ?? this.token),
        loading: loading ?? this.loading,
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState(loading: true)) {
    _load();
  }

  final Ref _ref;
  FlutterSecureStorage get _storage => _ref.read(_storageProvider);

  Future<void> _load() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final base = await _storage.read(key: _baseUrlKey);
      if (base != null && base.isNotEmpty) {
        _ref.read(apiBaseUrlProvider.notifier).state = base;
      }
      state = AuthState(token: token);
    } catch (e) {
      if (kDebugMode) debugPrint('auth: load failed — $e');
      state = const AuthState();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copy(loading: true);
    final api = ApiClient(baseUrl: _ref.read(apiBaseUrlProvider));
    try {
      final token = await api.login(email, password);
      await _storage.write(key: _tokenKey, value: token);
      state = AuthState(token: token);
    } finally {
      state = state.copy(loading: false);
    }
  }

  Future<void> setBaseUrl(String url) async {
    _ref.read(apiBaseUrlProvider.notifier).state = url;
    await _storage.write(key: _baseUrlKey, value: url);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    state = const AuthState();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

/// Builds an [ApiClient] using current auth + base URL. Watch this provider in
/// screens so re-login/logout swaps in a fresh client.
final apiClientProvider = Provider<ApiClient>((ref) {
  final base = ref.watch(apiBaseUrlProvider);
  final auth = ref.watch(authControllerProvider);
  return ApiClient(baseUrl: base, token: auth.token);
});
