import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../api/models.dart';
import '../auth/auth.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_chip.dart';
import 'profile_sheet.dart';

final _blogListProvider = FutureProvider.autoDispose<List<BlogPost>>((ref) {
  return ref.watch(apiClientProvider).listBlog();
});

class BlogListScreen extends ConsumerStatefulWidget {
  const BlogListScreen({super.key});

  @override
  ConsumerState<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends ConsumerState<BlogListScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_blogListProvider);
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: DesignAppBar(
        title: 'Blog',
        eyebrow: 'content',
        eyebrowNumber: '01',
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
        data: (posts) {
          final filtered = _filter(posts, _q);
          final live = posts.where((p) => p.published).length;
          return RefreshIndicator(
            onRefresh: () => ref.refresh(_blogListProvider.future),
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          isDense: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          hintText: 'Search posts, tags, slugs…',
                          prefixIcon: Icon(Icons.search, size: 16, color: t.ink3),
                          prefixIconConstraints: const BoxConstraints(minWidth: 38),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: '${filtered.length}',
                                style: AppText.eyebrow(context).copyWith(color: t.ink4),
                              ),
                              TextSpan(
                                text: '  —  POSTS  ·  ',
                                style: AppText.eyebrow(context),
                              ),
                              TextSpan(
                                text: '$live',
                                style: AppText.eyebrow(context).copyWith(color: t.ink4),
                              ),
                              TextSpan(
                                text: ' LIVE',
                                style: AppText.eyebrow(context),
                              ),
                            ]),
                          ),
                          Text('date ↓',
                              style: AppText.mono(context, size: 11, color: t.ink3)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverToBoxAdapter(child: _emptyState(context, posts.isEmpty)),
              SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) => _PostRow(post: filtered[i]),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/blog/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<BlogPost> _filter(List<BlogPost> posts, String q) {
    if (q.isEmpty) return posts;
    return posts.where((p) {
      if (p.title.toLowerCase().contains(q)) return true;
      if (p.slug.toLowerCase().contains(q)) return true;
      if (p.description.toLowerCase().contains(q)) return true;
      if (p.tags.any((t) => t.toLowerCase().contains(q))) return true;
      return false;
    }).toList();
  }

  Widget _emptyState(BuildContext context, bool noPostsAtAll) {
    final t = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(children: [
        Icon(noPostsAtAll ? Icons.edit_note : Icons.search_off,
            size: 48, color: t.ink4),
        const SizedBox(height: 16),
        Text(noPostsAtAll ? 'No posts yet — first idea?' : 'Nothing matches that.',
            style: AppText.serif(context, size: 22)),
        const SizedBox(height: 6),
        Text(
          noPostsAtAll
              ? 'Tap the + to draft your first post.'
              : 'Try a different word.',
          style: TextStyle(color: t.ink3, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class _PostRow extends ConsumerWidget {
  const _PostRow({required this.post});
  final BlogPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppTokens.of(context);
    final date = DateFormat('MMM yyyy').format(post.date);
    return InkWell(
      onTap: () => GoRouter.of(context).go('/blog/${post.slug}'),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: t.borderSoft)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: SizedBox(
                width: 36,
                height: 22,
                child: Switch(
                  value: post.published,
                  onChanged: (v) async {
                    final api = ref.read(apiClientProvider);
                    await api.updateBlog(post.slug, post..published = v);
                    ref.invalidate(_blogListProvider);
                  },
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.3,
                      color: post.published ? t.ink : t.ink3,
                      fontWeight: post.published ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8, runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(date,
                          style: AppText.mono(context, size: 10.5, color: t.ink4)),
                      for (final tag in post.tags) AppChip(label: tag),
                      if (!post.published)
                        const AppChip(label: 'draft', kind: ChipKind.warn),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Icon(Icons.chevron_right, size: 16, color: t.ink4),
            ),
          ],
        ),
      ),
    );
  }
}
