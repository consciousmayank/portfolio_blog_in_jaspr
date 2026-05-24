import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../api/models.dart';
import '../auth/auth.dart';

final _blogListProvider = FutureProvider.autoDispose<List<BlogPost>>((ref) {
  return ref.watch(apiClientProvider).listBlog();
});

class BlogListScreen extends ConsumerWidget {
  const BlogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_blogListProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/blog/new'),
        icon: const Icon(Icons.add),
        label: const Text('New post'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (posts) => RefreshIndicator(
          onRefresh: () => ref.refresh(_blogListProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _row(context, ref, posts[i]),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext ctx, WidgetRef ref, BlogPost p) {
    return Card(
      child: ListTile(
        title: Text(p.title),
        subtitle: Text(
            '${DateFormat.yMMMd().format(p.date)} · ${p.tags.join(' · ')}'),
        leading: Switch(
          value: p.published,
          onChanged: (v) async {
            final api = ref.read(apiClientProvider);
            await api.updateBlog(p.slug, p..published = v);
            ref.invalidate(_blogListProvider);
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => ctx.go('/blog/${p.slug}'),
        ),
        onTap: () => ctx.go('/blog/${p.slug}'),
      ),
    );
  }
}
