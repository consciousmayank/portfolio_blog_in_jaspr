import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../api/models.dart';
import '../auth/auth.dart';
import '../messages/last_seen.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_chip.dart';
import 'profile_sheet.dart';

final _messagesProvider = FutureProvider.autoDispose<List<ContactMessage>>((ref) {
  return ref.watch(apiClientProvider).listMessages();
});

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  ContactMessage? _selected;

  @override
  void initState() {
    super.initState();
    // Mark inbox as seen after first frame — clears the nav dot.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesLastSeenProvider.notifier).markSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_messagesProvider);
    final t = AppTokens.of(context);
    final lastSeen = ref.watch(messagesLastSeenProvider);
    final wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: DesignAppBar(
        title: 'Messages',
        eyebrow: 'inbox',
        eyebrowNumber: '05',
        onAvatarTap: () => showProfileSheet(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (msgs) {
          if (msgs.isEmpty) return _empty(context);
          final unread = lastSeen == null
              ? msgs.length
              : msgs.where((m) => m.createdAt.isAfter(lastSeen)).length;
          final list = _List(
            messages: msgs, unread: unread, lastSeen: lastSeen,
            selected: _selected,
            onSelect: wide ? (m) => setState(() => _selected = m) : null,
          );
          if (!wide) {
            return Column(children: [_meta(t, msgs.length, unread), Expanded(child: list)]);
          }
          final detail = _selected ?? msgs.first;
          return Row(children: [
            SizedBox(
              width: 360,
              child: Column(children: [
                _meta(t, msgs.length, unread),
                Expanded(child: list),
              ]),
            ),
            VerticalDivider(width: 1, color: t.borderSoft),
            Expanded(child: _Detail(message: detail)),
          ]);
        },
      ),
    );
  }

  Widget _meta(AppTokens t, int total, int unread) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(text: '$unread', style: AppText.eyebrow(context).copyWith(color: t.ink4)),
              TextSpan(text: '  —  UNREAD  ·  ', style: AppText.eyebrow(context)),
              TextSpan(text: '$total', style: AppText.eyebrow(context).copyWith(color: t.ink4)),
              TextSpan(text: '  TOTAL', style: AppText.eyebrow(context)),
            ]),
          ),
          Text('read-only', style: AppText.mono(context, size: 11, color: t.ink3)),
        ],
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final t = AppTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_outlined, size: 48, color: t.ink4),
          const SizedBox(height: 16),
          Text('All quiet.', style: AppText.serif(context, size: 22)),
          const SizedBox(height: 6),
          Text(
            'Form submissions land here. Nothing yet.',
            style: TextStyle(color: t.ink3, fontSize: 13),
          ),
        ]),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.messages,
    required this.unread,
    required this.lastSeen,
    required this.selected,
    required this.onSelect,
  });
  final List<ContactMessage> messages;
  final int unread;
  final DateTime? lastSeen;
  final ContactMessage? selected;
  final void Function(ContactMessage)? onSelect;

  bool _isUnread(ContactMessage m) =>
      lastSeen == null || m.createdAt.isAfter(lastSeen!);

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final m = messages[i];
        final isUnread = _isUnread(m);
        final isSelected = selected?.id == m.id;
        return InkWell(
          onTap: () {
            if (onSelect != null) {
              onSelect!(m);
            } else {
              _openDetailSheet(context, m);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? t.surface2 : Colors.transparent,
              border: Border(top: BorderSide(color: t.borderSoft)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
            child: Stack(children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 22, height: 22,
                  margin: const EdgeInsets.only(top: 2, right: 12),
                  decoration: BoxDecoration(
                    color: m.delivered ? t.successSoft : t.dangerSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    m.delivered ? Icons.check : Icons.priority_high,
                    size: 13,
                    color: m.delivered ? t.success : t.danger,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              m.name.isEmpty ? '— no sender —' : m.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                                color: m.name.isEmpty ? t.ink3 : t.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: t.accent, shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          Text(
                            _ago(m.createdAt),
                            style: AppText.mono(context, size: 10.5, color: t.ink4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        m.subject,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnread ? t.ink2 : t.ink3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ]),
              if (isSelected)
                Positioned(left: -8, top: 0, bottom: 0,
                    child: Container(width: 2, color: t.accent)),
            ]),
          ),
        );
      },
    );
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    if (d.inDays < 7) return '${d.inDays}d';
    if (d.inDays < 30) return '${d.inDays ~/ 7}w';
    return DateFormat.MMMd().format(t);
  }

  void _openDetailSheet(BuildContext context, ContactMessage m) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: _Detail(message: m),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.message});
  final ContactMessage message;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final m = message;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.borderSoft)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            StatusChip(
              label: m.delivered ? 'delivered' : 'failed',
              kind: m.delivered ? ChipKind.success : ChipKind.danger,
            ),
            const SizedBox(width: 10),
            Text(
              DateFormat('MMM d · HH:mm').format(m.createdAt.toLocal()),
              style: AppText.mono(context, size: 11, color: t.ink3),
            ),
          ]),
          const SizedBox(height: 10),
          Text(m.subject,
              style: AppText.serif(context, size: 26).copyWith(height: 1.1)),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'from '),
              TextSpan(
                  text: m.name.isEmpty ? '— no sender —' : m.name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              TextSpan(
                  text: '  ·  ${m.email}',
                  style: TextStyle(color: t.ink3)),
            ]),
            style: TextStyle(fontSize: 13.5, color: t.ink2),
          ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: SelectableText(
          m.message,
          style: TextStyle(fontSize: 14, height: 1.6, color: t.ink),
        ),
      ),
      Divider(height: 1, color: t.borderSoft),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: DefaultTextStyle(
          style: AppText.mono(context, size: 11, color: t.ink3),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (m.ip != null) Text('ip     ${m.ip}'),
            if (m.userAgent != null)
              Text('ua     ${m.userAgent!}', maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ),
      Divider(height: 1, color: t.borderSoft),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(children: [
          FilledButton.icon(
            onPressed: () {
              final mailto = 'mailto:${m.email}?subject=Re: ${Uri.encodeQueryComponent(m.subject)}';
              Clipboard.setData(ClipboardData(text: mailto));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('mailto:link copied.')),
              );
            },
            icon: const Icon(Icons.mail_outline, size: 16),
            label: const Text('Reply (copy mailto)'),
          ),
        ]),
      ),
    ]);
  }
}
