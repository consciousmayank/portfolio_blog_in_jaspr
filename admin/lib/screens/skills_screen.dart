import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models.dart';
import '../auth/auth.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_chip.dart';
import 'profile_sheet.dart';

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
    final t = AppTokens.of(context);
    return DefaultTabController(
      length: _listKeys.length + 1,
      child: Scaffold(
        backgroundColor: t.bg,
        appBar: DesignAppBar(
          title: 'Skills',
          eyebrow: 'stack',
          eyebrowNumber: '03',
          onAvatarTap: () => showProfileSheet(context),
        ),
        body: Column(children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'CORE'),
              Tab(text: 'STATE'),
              Tab(text: 'AI STACK'),
              Tab(text: 'ARCH'),
              Tab(text: 'WEB & OPS'),
              Tab(text: 'PLATFORMS'),
            ],
          ),
          Expanded(
            child: TabBarView(children: [
              const _CoreTab(),
              ..._listKeys.map((k) => _ListTab(listKey: k)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _CoreTab extends ConsumerWidget {
  const _CoreTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_skillsProvider);
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (skills) => RefreshIndicator(
          onRefresh: () => ref.refresh(_skillsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: skills.length,
            itemBuilder: (_, i) => _SkillRow(
              skill: skills[i],
              onTap: () => _edit(context, ref, skills[i]),
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
            TextField(controller: name, decoration: const InputDecoration(labelText: 'NAME')),
            const SizedBox(height: 8),
            TextField(controller: years, decoration: const InputDecoration(labelText: 'YEARS'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Percent'),
              Expanded(child: Slider(value: percent, min: 0, max: 100, divisions: 100, label: percent.toStringAsFixed(0), onChanged: (v) => setS(() => percent = v))),
              SizedBox(width: 36, child: Text(percent.toStringAsFixed(0), textAlign: TextAlign.right)),
            ]),
            SwitchListTile(
              title: const Text('Hot'),
              dense: true,
              value: hot,
              onChanged: (v) => setS(() => hot = v),
              contentPadding: EdgeInsets.zero,
            ),
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

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill, required this.onTap});
  final CoreSkill skill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.borderSoft)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(skill.name,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
            if (skill.hot) ...[
              const SizedBox(width: 8),
              const AppChip(label: 'hot', kind: ChipKind.accent, dense: true),
            ],
            const Spacer(),
            Text('${skill.years} yrs',
                style: AppText.mono(context, size: 11, color: t.ink3)),
            const SizedBox(width: 10),
            SizedBox(
              width: 36,
              child: Text('${skill.percent}%',
                  textAlign: TextAlign.right,
                  style: AppText.mono(context, size: 12.5, color: t.ink)),
            ),
          ]),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: skill.percent / 100,
            backgroundColor: t.surface3,
            color: t.accent,
            minHeight: 4,
            borderRadius: BorderRadius.circular(999),
          ),
        ]),
      ),
    );
  }
}

class _ListTab extends ConsumerStatefulWidget {
  const _ListTab({required this.listKey});
  final String listKey;

  @override
  ConsumerState<_ListTab> createState() => _ListTabState();
}

class _ListTabState extends ConsumerState<_ListTab> {
  List<String>? _values;
  final _add = TextEditingController();
  bool _dirty = false;

  Widget _editor(BuildContext context) {
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      floatingActionButton: _dirty
          ? FloatingActionButton.extended(
              onPressed: () async {
                await ref.read(apiClientProvider).putList(widget.listKey, _values!);
                setState(() => _dirty = false);
                ref.invalidate(_listProvider(widget.listKey));
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Saved.')));
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _add,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Add value, press Enter',
                  prefixIcon: Icon(Icons.add, size: 16, color: t.ink3),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36),
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
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
          ]),
          const SizedBox(height: 14),
          Expanded(
            child: ReorderableListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _values!.length,
              onReorder: (oldI, newI) {
                setState(() {
                  if (newI > oldI) newI -= 1;
                  final v = _values!.removeAt(oldI);
                  _values!.insert(newI, v);
                  _dirty = true;
                });
              },
              proxyDecorator: (child, _, __) => Material(
                color: Colors.transparent,
                child: child,
              ),
              itemBuilder: (_, i) => ListTile(
                key: ValueKey('${widget.listKey}_$i'),
                leading: Icon(Icons.drag_indicator, color: t.ink4, size: 18),
                title: Text(_values![i]),
                trailing: IconButton(
                  icon: Icon(Icons.close, size: 18, color: t.ink3),
                  onPressed: () => setState(() {
                    _values!.removeAt(i);
                    _dirty = true;
                  }),
                ),
                shape: Border(bottom: BorderSide(color: t.borderSoft)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_listProvider(widget.listKey));
    if (_values == null) {
      return async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (v) {
          _values = List.of(v);
          return _editor(context);
        },
      );
    }
    return _editor(context);
  }
}
