import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models.dart';
import '../auth/auth.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_chip.dart';
import '../widgets/eyebrow.dart';
import 'profile_sheet.dart';

final _experimentsProvider = FutureProvider.autoDispose<List<ExperimentCard>>((ref) {
  return ref.watch(apiClientProvider).listExperiments();
});

class ExperimentsScreen extends ConsumerWidget {
  const ExperimentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_experimentsProvider);
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: DesignAppBar(
        title: 'Experiments',
        eyebrow: 'workshop',
        eyebrowNumber: '04',
        onAvatarTap: () => showProfileSheet(context),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: t.accent,
        foregroundColor: Colors.white,
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cards) => RefreshIndicator(
          onRefresh: () => ref.refresh(_experimentsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
            itemCount: cards.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ExperimentCard(
                card: cards[i],
                onTap: () => _edit(context, ref, cards[i]),
                onToggleActive: (next) async {
                  final api = ref.read(apiClientProvider);
                  final updated = cards[i]..isActive = next;
                  await api.updateExperiment(cards[i].id!, updated);
                  ref.invalidate(_experimentsProvider);
                },
                onDelete: () async {
                  final confirmed = await _confirmDelete(context, cards[i]);
                  if (!confirmed) return;
                  await ref.read(apiClientProvider).deleteExperiment(cards[i].id!);
                  ref.invalidate(_experimentsProvider);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, ExperimentCard c) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this experiment?'),
        content: Text(
          'This permanently removes "${c.title}" (${c.code}) and all of '
          'its demo lines. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return r == true;
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, ExperimentCard? c) async {
    final code = TextEditingController(text: c?.code);
    final status = TextEditingController(text: c?.status);
    final title = TextEditingController(text: c?.title);
    final body = TextEditingController(text: c?.body);
    final meta = TextEditingController(text: c?.meta);
    final link = TextEditingController(text: c?.link);
    final span = TextEditingController(text: (c?.span ?? 4).toString());
    final sort = TextEditingController(text: (c?.sortIndex ?? 0).toString());
    final demo = List<List<String>>.from(c?.demo ?? const []);
    var isActive = c?.isActive ?? true;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          title: Text(c == null ? 'New experiment' : 'Edit ${c.code}'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  Expanded(child: TextField(controller: code, decoration: const InputDecoration(labelText: 'CODE'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: status, decoration: const InputDecoration(labelText: 'STATUS'))),
                  const SizedBox(width: 12),
                  SizedBox(width: 70, child: TextField(controller: span, decoration: const InputDecoration(labelText: 'SPAN'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  SizedBox(width: 70, child: TextField(controller: sort, decoration: const InputDecoration(labelText: 'SORT', helperText: 'lower first'), keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: 8),
                TextField(controller: title, decoration: const InputDecoration(labelText: 'TITLE')),
                const SizedBox(height: 8),
                TextField(controller: body, decoration: const InputDecoration(labelText: 'BODY'), maxLines: 3),
                const SizedBox(height: 8),
                TextField(controller: meta, decoration: const InputDecoration(labelText: 'META')),
                const SizedBox(height: 8),
                TextField(
                  controller: link,
                  decoration: const InputDecoration(
                    labelText: 'LINK (optional)',
                    hintText: 'https://example.com — opens in a new tab',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text('Inactive experiments are hidden from the public site'),
                  value: isActive,
                  onChanged: (v) => setS(() => isActive = v),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Eyebrow(label: 'demo lines · line + style'),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < demo.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(key: ValueKey('demo_$i'), children: [
                      Expanded(child: TextField(
                        controller: TextEditingController(text: demo[i][0]),
                        decoration: const InputDecoration(labelText: 'LINE'),
                        onChanged: (v) => demo[i][0] = v,
                      )),
                      const SizedBox(width: 8),
                      SizedBox(width: 90, child: TextField(
                        controller: TextEditingController(text: demo[i].length > 1 ? demo[i][1] : ''),
                        decoration: const InputDecoration(labelText: 'STYLE'),
                        onChanged: (v) {
                          if (demo[i].length > 1) {
                            demo[i][1] = v;
                          } else {
                            demo[i].add(v);
                          }
                        },
                      )),
                      IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 18),
                          onPressed: () => setS(() => demo.removeAt(i))),
                    ]),
                  ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add line'),
                  onPressed: () => setS(() => demo.add(['', 'mu'])),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        );
      }),
    );
    if (ok != true) return;
    final api = ref.read(apiClientProvider);
    final next = ExperimentCard(
      id: c?.id, code: code.text.trim(), status: status.text.trim(),
      title: title.text.trim(), body: body.text, meta: meta.text,
      span: int.tryParse(span.text) ?? 4,
      sortIndex: int.tryParse(sort.text) ?? 0,
      link: link.text.trim(),
      isActive: isActive,
      demo: demo,
    );
    if (c == null) {
      await api.createExperiment(next);
    } else {
      await api.updateExperiment(c.id!, next);
    }
    ref.invalidate(_experimentsProvider);
  }
}

class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({
    required this.card,
    required this.onTap,
    required this.onDelete,
    required this.onToggleActive,
  });
  final ExperimentCard card;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

  ChipKind _kindOf(String status) {
    final s = status.toLowerCase();
    if (s.contains('live') || s.contains('ship')) return ChipKind.success;
    if (s.contains('pause') || s.contains('paused') || s.contains('open')) return ChipKind.warn;
    if (s.contains('kill') || s.contains('drop')) return ChipKind.danger;
    return ChipKind.accent;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final kind = _kindOf(card.status);
    final body = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(card.code,
                  style: AppText.mono(context, size: 10.5, color: t.ink3)),
              const SizedBox(width: 8),
              StatusChip(label: card.status, kind: kind),
              const Spacer(),
              Text('sort ${card.sortIndex} · span ${card.span}',
                  style: AppText.mono(context, size: 10.5, color: t.ink4)),
              const SizedBox(width: 6),
              SizedBox(
                width: 36,
                height: 24,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Switch(
                    value: card.isActive,
                    onChanged: onToggleActive,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete',
                icon: Icon(Icons.delete_outline, size: 18, color: t.ink3),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(),
              ),
            ]),
            const SizedBox(height: 10),
            Text(card.title,
                style: AppText.serif(context, size: 22).copyWith(height: 1.1)),
            const SizedBox(height: 6),
            Text(card.body,
                style: TextStyle(fontSize: 13, color: t.ink2, height: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: t.border, style: BorderStyle.solid),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow(label: 'demo lines'),
                  const SizedBox(height: 6),
                  for (final d in card.demo)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Icon(Icons.drag_indicator, size: 14, color: t.ink4),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            d.isNotEmpty ? d[0] : '',
                            style: AppText.mono(context, size: 11.5),
                          ),
                        ),
                        if (d.length > 1 && d[1].isNotEmpty)
                          AppChip(label: d[1], dense: true),
                      ]),
                    ),
                ],
              ),
            ),
            if (card.link.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.open_in_new, size: 14, color: t.ink3),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    card.link,
                    style: AppText.mono(context, size: 11.5, color: t.ink3),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ],
          ]),
        ),
      ),
    );
    return card.isActive ? body : Opacity(opacity: 0.5, child: body);
  }
}
