import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models.dart';
import '../auth/auth.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_chip.dart';
import 'profile_sheet.dart';

final _rolesProvider = FutureProvider.autoDispose<List<Role>>((ref) {
  return ref.watch(apiClientProvider).listRoles();
});

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_rolesProvider);
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: DesignAppBar(
        title: 'Timeline',
        eyebrow: 'career',
        eyebrowNumber: '02',
        onAvatarTap: () => showProfileSheet(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.reorder, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (roles) => RefreshIndicator(
          onRefresh: () => ref.refresh(_rolesProvider.future),
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _header(context, roles.length)),
            SliverList.builder(
              itemCount: roles.length,
              itemBuilder: (_, i) => _RoleRow(
                role: roles[i],
                first: i == 0,
                onTap: () => _edit(context, ref, roles[i]),
                onDelete: () async {
                  await ref.read(apiClientProvider).deleteRole(roles[i].id!);
                  ref.invalidate(_rolesProvider);
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, int count) {
    final t = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(text: '$count ', style: AppText.serif(context, size: 28)),
              TextSpan(
                text: 'years of',
                style: AppText.serif(context, size: 28, italic: true)
                    .copyWith(color: t.ink3),
              ),
              TextSpan(text: ' shipping.', style: AppText.serif(context, size: 28)),
            ]),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag a row to reorder. Tap to edit company, title, span, '
            'or the lead chip.',
            style: TextStyle(fontSize: 13, color: t.ink3, height: 1.5),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Role? role) async {
    final company = TextEditingController(text: role?.company);
    final title = TextEditingController(text: role?.title);
    final start = TextEditingController(text: role?.start.toString());
    final end = TextEditingController(text: role?.end.toString());
    var alt = role?.alt ?? false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          title: Text(role == null ? 'New role' : 'Edit role'),
          content: SizedBox(
            width: 360,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: company, decoration: const InputDecoration(labelText: 'COMPANY')),
              const SizedBox(height: 8),
              TextField(controller: title, decoration: const InputDecoration(labelText: 'TITLE')),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: start, decoration: const InputDecoration(labelText: 'START'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: end, decoration: const InputDecoration(labelText: 'END'), keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 4),
              SwitchListTile(
                title: const Text('Lead role'),
                dense: true,
                value: alt,
                onChanged: (v) => setS(() => alt = v),
                contentPadding: EdgeInsets.zero,
              ),
            ]),
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
    final next = Role(
      id: role?.id,
      company: company.text.trim(),
      title: title.text.trim(),
      start: double.tryParse(start.text) ?? 0,
      end: double.tryParse(end.text) ?? 0,
      alt: alt,
      sortIndex: role?.sortIndex ?? 0,
    );
    if (role == null) {
      await api.createRole(next);
    } else {
      await api.updateRole(role.id!, next);
    }
    ref.invalidate(_rolesProvider);
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow({
    required this.role,
    required this.first,
    required this.onTap,
    required this.onDelete,
  });
  final Role role;
  final bool first;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final span = '${role.start.toStringAsFixed(0)} — ${role.end.toStringAsFixed(0)}';
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: first ? t.surface2 : Colors.transparent,
          border: Border(top: BorderSide(color: t.borderSoft)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 14, 16, 14),
        child: Stack(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.drag_indicator, size: 18, color: t.ink4),
            const SizedBox(width: 6),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(role.company, style: AppText.serif(context, size: 18)),
                  if (role.alt) ...[
                    const SizedBox(width: 8),
                    const AppChip(label: 'lead', kind: ChipKind.lead, dense: true),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(role.title, style: TextStyle(fontSize: 13, color: t.ink2)),
                const SizedBox(height: 5),
                Text(span, style: AppText.mono(context, size: 11, color: t.ink3)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Icon(Icons.chevron_right, size: 16, color: t.ink4),
            ),
          ]),
          if (first)
            Positioned(
              left: -2, top: 0, bottom: 0,
              child: Container(width: 2, color: t.accent),
            ),
        ]),
      ),
    );
  }
}
