import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/models.dart';
import '../auth/auth.dart';

final _experimentsProvider = FutureProvider.autoDispose<List<ExperimentCard>>((ref) {
  return ref.watch(apiClientProvider).listExperiments();
});

class ExperimentsScreen extends ConsumerWidget {
  const ExperimentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_experimentsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('New experiment'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cards) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cards.length,
          itemBuilder: (_, i) => Card(
            child: ListTile(
              title: Text('${cards[i].code} · ${cards[i].title}'),
              subtitle: Text('${cards[i].status} · ${cards[i].demo.length} demo lines'),
              onTap: () => _edit(context, ref, cards[i]),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
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

  Future<void> _edit(BuildContext context, WidgetRef ref, ExperimentCard? c) async {
    final code = TextEditingController(text: c?.code);
    final status = TextEditingController(text: c?.status);
    final title = TextEditingController(text: c?.title);
    final body = TextEditingController(text: c?.body);
    final meta = TextEditingController(text: c?.meta);
    final span = TextEditingController(text: (c?.span ?? 4).toString());
    final demo = List<List<String>>.from(c?.demo ?? const []);

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
                  Expanded(child: TextField(controller: code, decoration: const InputDecoration(labelText: 'Code (01, 02…)'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: status, decoration: const InputDecoration(labelText: 'Status (Shipping/Open/Concept)'))),
                  const SizedBox(width: 12),
                  SizedBox(width: 80, child: TextField(controller: span, decoration: const InputDecoration(labelText: 'Span'), keyboardType: TextInputType.number)),
                ]),
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: body, decoration: const InputDecoration(labelText: 'Body'), maxLines: 3),
                TextField(controller: meta, decoration: const InputDecoration(labelText: 'Meta')),
                const SizedBox(height: 12),
                const Align(alignment: Alignment.centerLeft, child: Text('Demo lines (line + style: pr/ok/mu)')),
                for (var i = 0; i < demo.length; i++)
                  Row(key: ValueKey('demo_$i'), children: [
                    Expanded(child: TextField(
                      controller: TextEditingController(text: demo[i][0]),
                      decoration: const InputDecoration(labelText: 'Line'),
                      onChanged: (v) => demo[i][0] = v,
                    )),
                    const SizedBox(width: 8),
                    SizedBox(width: 80, child: TextField(
                      controller: TextEditingController(text: demo[i].length > 1 ? demo[i][1] : ''),
                      decoration: const InputDecoration(labelText: 'Style'),
                      onChanged: (v) {
                        if (demo[i].length > 1) {
                          demo[i][1] = v;
                        } else {
                          demo[i].add(v);
                        }
                      },
                    )),
                    IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setS(() => demo.removeAt(i))),
                  ]),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add demo line'),
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
      id: c?.id,
      code: code.text.trim(),
      status: status.text.trim(),
      title: title.text.trim(),
      body: body.text,
      meta: meta.text,
      span: int.tryParse(span.text) ?? 4,
      sortIndex: c?.sortIndex ?? 0,
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
