import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../styles/theme.dart';
import 'skill_chip.dart';

class BlogCard extends StatelessComponent {
  final String title;
  final String date;
  final List<String> tags;
  final String excerpt;
  final String slug;

  const BlogCard({
    required this.title,
    required this.date,
    required this.tags,
    required this.excerpt,
    required this.slug,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'blog-card card', [
      div(classes: 'blog-card-meta', [
        span(classes: 'blog-card-date text-muted', [.text(date)]),
      ]),
      h3(classes: 'blog-card-title', [
        Link(to: '/blog/$slug', child: .text(title)),
      ]),
      p(classes: 'blog-card-excerpt', [.text(excerpt)]),
      div(classes: 'blog-card-tags', [
        for (final tag in tags) SkillChip(tag),
      ]),
      div(classes: 'blog-card-footer', [
        Link(
          to: '/blog/$slug',
          child: span(classes: 'blog-card-read-more', [.text('Read More →')]),
        ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.blog-card', [
      css('&').styles(
        display: .flex,
        flexDirection: .column,
      ),
      css('.blog-card-meta').styles(
        margin: .only(bottom: 0.5.rem),
      ),
      css('.blog-card-date').styles(fontSize: 0.85.rem),
      css('.blog-card-title').styles(
        fontSize: 1.15.rem,
        fontWeight: .w700,
        margin: .only(bottom: 0.5.rem),
      ),
      css('.blog-card-title a').styles(
        color: colorText,
        textDecoration: TextDecoration(line: .none),
      ),
      css('.blog-card-title a:hover').styles(color: colorPrimary),
      css('.blog-card-excerpt').styles(
        fontSize: 0.9.rem,
        color: colorMuted,
        flex: Flex(grow: 1),
        margin: .only(bottom: 0.75.rem),
      ),
      css('.blog-card-tags').styles(
        display: .flex,
        flexDirection: .row,
        flexWrap: .wrap,
        margin: .only(bottom: 0.75.rem),
      ),
      css('.blog-card-tags .skill-chip').styles(margin: .only(right: 0.4.rem, bottom: 0.4.rem)),
      css('.blog-card-footer').styles(margin: .only(top: .auto)),
      css('.blog-card-read-more').styles(
        color: colorSecondary,
        fontWeight: .w600,
        fontSize: 0.9.rem,
      ),
    ]),
  ];
}
