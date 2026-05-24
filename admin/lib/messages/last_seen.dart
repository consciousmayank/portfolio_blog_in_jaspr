import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models.dart';
import '../auth/auth.dart';
import '../theme/theme_controller.dart';

const _lastSeenKey = 'messages_last_seen';

/// Persists the timestamp the user last opened the Messages screen.
/// `unreadCountProvider` uses it to render the dot indicator on the nav.
class MessagesLastSeen extends StateNotifier<DateTime?> {
  MessagesLastSeen(this._ref) : super(null) {
    _load();
  }
  final Ref _ref;

  Future<void> _load() async {
    try {
      final raw = await _ref.read(themeStorageProvider).read(key: _lastSeenKey);
      if (raw != null) state = DateTime.tryParse(raw);
    } catch (_) {/* leave null on failure */}
  }

  Future<void> markSeen() async {
    final now = DateTime.now().toUtc();
    state = now;
    await _ref
        .read(themeStorageProvider)
        .write(key: _lastSeenKey, value: now.toIso8601String());
  }
}

final messagesLastSeenProvider =
    StateNotifierProvider<MessagesLastSeen, DateTime?>(
  (ref) => MessagesLastSeen(ref),
);

/// Reactive count of messages with createdAt > lastSeen. Watches the API
/// for live message data + the lastSeen notifier.
final messagesUnreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (!auth.isAuthed) return 0;
  final lastSeen = ref.watch(messagesLastSeenProvider);
  final List<ContactMessage> all =
      await ref.watch(apiClientProvider).listMessages();
  if (lastSeen == null) return all.length;
  return all.where((m) => m.createdAt.isAfter(lastSeen)).length;
});
