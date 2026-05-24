import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models.dart';
import '../auth/auth.dart';

final _rolesProvider = FutureProvider.autoDispose<List<Role>>((ref) {
  return ref.watch(apiClientProvider).listRoles();
});

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_rolesProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('New role'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (roles) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: roles.length,
          itemBuilder: (_, i) => Card(
            child: ListTile(
              title: Text('${roles[i].company} — ${roles[i].title}'),
              subtitle: Text('${roles[i].start} → ${roles[i].end}${roles[i].alt ? "  · lead" : ""}'),
              onTap: () => _edit(context, ref, roles[i]),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await ref.read(apiClientProvider).deleteRole(roles[i].id!);
                  ref.invalidate(_rolesProvider);
                },
              ),
            ),
          ),
        ),
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
              TextField(controller: company, decoration: const InputDecoration(labelText: 'Company')),
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              Row(children: [
                Expanded(child: TextField(controller: start, decoration: const InputDecoration(labelText: 'Start (e.g. 2021.5)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: end, decoration: const InputDecoration(labelText: 'End (e.g. 2024)'), keyboardType: TextInputType.number)),
              ]),
              SwitchListTile(
                title: const Text('Lead role'),
                value: alt,
                onChanged: (v) => setS(() => alt = v),
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
