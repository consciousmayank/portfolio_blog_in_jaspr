import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../api/models.dart';
import '../auth/auth.dart';

final _messagesProvider = FutureProvider.autoDispose<List<ContactMessage>>((ref) {
  return ref.watch(apiClientProvider).listMessages();
});

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_messagesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (msgs) => RefreshIndicator(
        onRefresh: () => ref.refresh(_messagesProvider.future),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: msgs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _card(context, msgs[i]),
        ),
      ),
    );
  }

  Widget _card(BuildContext ctx, ContactMessage m) {
    return Card(
      child: ExpansionTile(
        leading: Icon(
          m.delivered ? Icons.check_circle_outline : Icons.error_outline,
          color: m.delivered ? Colors.green : Colors.redAccent,
        ),
        title: Text('${m.name} · ${m.subject}'),
        subtitle: Text(
            '${m.email} · ${DateFormat.yMMMd().add_jm().format(m.createdAt.toLocal())}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SelectableText(m.message),
              const SizedBox(height: 12),
              if (m.ip != null) Text('IP: ${m.ip}', style: const TextStyle(color: Colors.grey)),
              if (m.userAgent != null) Text('UA: ${m.userAgent}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                FilledButton.icon(
                  icon: const Icon(Icons.reply),
                  label: const Text('Reply'),
                  onPressed: () {
                    // mailto: works on all targets via launchUrl, but adding url_launcher
                    // is overkill for one button; show address in dialog instead.
                    showDialog(context: ctx, builder: (_) => AlertDialog(
                      title: const Text('Reply to'),
                      content: SelectableText('mailto:${m.email}?subject=Re: ${m.subject}'),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                    ));
                  },
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
