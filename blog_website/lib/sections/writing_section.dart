import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/api_client.dart';

class WritingSection extends StatelessComponent {
  const WritingSection({required this.posts, super.key});

  final List<BlogPost> posts;

  @override
  Component build(BuildContext context) {
    return section(id: 'writing', classes: 'wr', [
      div(classes: 'wrap', [
        _head(),
        _feed(),
        _foot(),
      ]),
    ]);
  }

  static Component _head() {
    return div(classes: 'wr-head', [
      div([
        span(classes: 'eyebrow', [.text('05 — Field notes')]),
        h2([
          .text('Long-form, in my '),
          em([.text('own')]),
          .text(' voice.'),
        ]),
      ]),
      span(classes: 'pill', [
        span(classes: 'dot', []),
        .text('writing weekly · since 2024'),
      ]),
    ]);
  }

  Component _feed() {
    return div(classes: 'wr-feed', [
      for (final post in posts) _row(post),
    ]);
  }

  static String _formatDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length < 2) return isoDate;
    const months = [
      '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final month = int.tryParse(parts[1]) ?? 1;
    return '${months[month]} ${parts[0]}';
  }

  static Component _row(BlogPost post) {
    final firstTag = post.tags.isNotEmpty ? post.tags.first : '';
    return a(href: '/blog/${post.slug}', classes: 'wr-row', [
      div(classes: 'date', [.text(_formatDate(post.date))]),
      div([
        span(classes: 'title', [.text(post.title)]),
        div(classes: 'dek', [.text(post.description)]),
      ]),
      div(classes: 'meta', [
        span(classes: 'tag', [.text('/ $firstTag')]),
      ]),
    ]);
  }

  static Component _foot() {
    return div(classes: 'wr-foot', [
      span([
        .text('↳ Posts from '),
        a(
          href: '#writing',
          styles: Styles(raw: {'color': 'var(--ink)'}),
          [.text('mayankjoshi.in')],
        ),
      ]),
    ]);
  }
}
