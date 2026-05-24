import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models.dart';
import '../auth/auth.dart';

const _listKeys = ['stateManagement', 'aiStack', 'architecture', 'webOps', 'platforms'];

final _skillsProvider = FutureProvider.autoDispose<List<CoreSkill>>((ref) {
  return ref.watch(apiClientProvider).listSkills();
});

final _listProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, key) {
  return ref.watch(apiClientProvider).getList(key);
});

class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: _listKeys.length + 1,
      child: Column(children: [
        const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'Core skills'),
            Tab(text: 'stateManagement'),
            Tab(text: 'aiStack'),
            Tab(text: 'architecture'),
            Tab(text: 'webOps'),
            Tab(text: 'platforms'),
          ],
        ),
        Expanded(
          child: TabBarView(children: [
            _CoreSkillsTab(),
            ..._listKeys.map((k) => _ListEditorTab(key: ValueKey(k), listKey: k)),
          ]),
        ),
      ]),
    );
  }
}

class _CoreSkillsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_skillsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('New skill'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (skills) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: skills.length,
          itemBuilder: (_, i) => Card(
            child: ListTile(
              title: Text(skills[i].name),
              subtitle: Text('${skills[i].years} yrs · ${skills[i].percent}%${skills[i].hot ? " · hot" : ""}'),
              onTap: () => _edit(context, ref, skills[i]),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await ref.read(apiClientProvider).deleteSkill(skills[i].id!);
                  ref.invalidate(_skillsProvider);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext ctx, WidgetRef ref, CoreSkill? s) async {
    final name = TextEditingController(text: s?.name);
    final years = TextEditingController(text: s?.years.toString() ?? '0');
    var percent = (s?.percent ?? 50).toDouble();
    var hot = s?.hot ?? false;
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          title: Text(s == null ? 'New skill' : 'Edit ${s.name}'),
          content: SizedBox(width: 320, child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: years, decoration: const InputDecoration(labelText: 'Years'), keyboardType: TextInputType.number),
            Row(children: [
              const Text('Percent'),
              Expanded(child: Slider(value: percent, min: 0, max: 100, divisions: 100, label: percent.toStringAsFixed(0), onChanged: (v) => setS(() => percent = v))),
              Text(percent.toStringAsFixed(0)),
            ]),
            SwitchListTile(title: const Text('Hot'), value: hot, onChanged: (v) => setS(() => hot = v)),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        );
      }),
    );
    if (ok != true) return;
    final api = ref.read(apiClientProvider);
    final next = CoreSkill(
      id: s?.id,
      name: name.text.trim(),
      years: int.tryParse(years.text) ?? 0,
      percent: percent.round(),
      hot: hot,
      sortIndex: s?.sortIndex ?? 0,
    );
    if (s == null) {
      await api.createSkill(next);
    } else {
      await api.updateSkill(s.id!, next);
    }
    ref.invalidate(_skillsProvider);
  }
}

class _ListEditorTab extends ConsumerStatefulWidget {
  const _ListEditorTab({required this.listKey, super.key});
  final String listKey;

  @override
  ConsumerState<_ListEditorTab> createState() => _ListEditorTabState();
}

class _ListEditorTabState extends ConsumerState<_ListEditorTab> {
  List<String>? _values;
  final _add = TextEditingController();
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_listProvider(widget.listKey));
    if (_values == null) {
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (v) {
          _values = List.of(v);
          return _editor();
        },
      );
    }
    return _editor();
  }

  Widget _editor() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _add,
                decoration: const InputDecoration(hintText: 'Add value, press Enter'),
                onSubmitted: (v) {
                  if (v.trim().isEmpty) return;
                  setState(() {
                    _values!.add(v.trim());
                    _add.clear();
                    _dirty = true;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _dirty
                  ? () async {
                      await ref
                          .read(apiClientProvider)
                          .putList(widget.listKey, _values!);
                      setState(() => _dirty = false);
                      ref.invalidate(_listProvider(widget.listKey));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved.')));
                      }
                    }
                  : null,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _values!.length,
              onReorder: (oldI, newI) {
                setState(() {
                  if (newI > oldI) newI -= 1;
                  final v = _values!.removeAt(oldI);
                  _values!.insert(newI, v);
                  _dirty = true;
                });
              },
              itemBuilder: (_, i) => Card(
                key: ValueKey('${widget.listKey}_$i'),
                child: ListTile(
                  leading: const Icon(Icons.drag_handle),
                  title: Text(_values![i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() {
                      _values!.removeAt(i);
                      _dirty = true;
                    }),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
