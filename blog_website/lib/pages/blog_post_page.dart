import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:markdown/markdown.dart' as md;

import '../components/skill_chip.dart';
import '../data/blog_posts.dart';
import '../styles/theme.dart';

class BlogPostPage extends StatelessComponent {
  final BlogPost post;
  const BlogPostPage({required this.post, super.key});

  @override
  Component build(BuildContext context) {
    final htmlBody = md.markdownToHtml(
      post.contentMarkdown,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    return div(classes: 'container', [
      section(classes: 'section', [
        div(classes: 'post-back', [
          Link(to: '/blog', child: span(classes: 'post-back-link', [.text('← Back to Blog')])),
        ]),
        article(classes: 'post-article', [
          header(classes: 'post-header', [
            h1(classes: 'post-title', [.text(post.title)]),
            div(classes: 'post-meta', [
              span(classes: 'post-date text-muted', [.text(post.date)]),
            ]),
            div(classes: 'post-tags', [
              for (final tag in post.tags) SkillChip(tag),
            ]),
          ]),
          div(classes: 'post-body', [RawText(htmlBody)]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.post-back').styles(margin: .only(bottom: 1.5.rem)),
    css('.post-back-link').styles(
      color: colorMuted,
      fontSize: 0.9.rem,
      cursor: .pointer,
    ),
    css('.post-back-link:hover').styles(color: colorPrimary),
    css('.post-header').styles(margin: .only(bottom: 2.rem)),
    css('.post-title').styles(
      fontSize: 2.rem,
      fontWeight: .w700,
      margin: .only(bottom: 0.75.rem),
    ),
    css('.post-meta').styles(margin: .only(bottom: 0.75.rem)),
    css('.post-date').styles(fontSize: 0.9.rem),
    css('.post-tags').styles(
      display: .flex,
      flexWrap: .wrap,
      margin: .only(top: 0.5.rem),
    ),
    css('.post-tags .skill-chip').styles(margin: .only(right: 0.4.rem, bottom: 0.4.rem)),
    css('.post-body', [
      css('h1, h2, h3').styles(
        margin: .symmetric(vertical: 1.25.rem),
        color: colorText,
      ),
      css('p').styles(
        margin: .only(bottom: 1.rem),
        fontSize: 1.rem,
      ),
      css('code').styles(
        fontFamily: const .list([FontFamily('Fira Code'), FontFamilies.monospace]),
        fontSize: 0.875.rem,
        backgroundColor: colorSurface,
        padding: .symmetric(horizontal: 0.3.rem, vertical: 0.15.rem),
        radius: .all(.circular(3.px)),
      ),
      css('pre').styles(
        backgroundColor: colorSurface,
        padding: .all(1.rem),
        radius: .all(.circular(6.px)),
        overflow: .clip,
        margin: .only(bottom: 1.25.rem),
      ),
      css('pre code').styles(
        backgroundColor: Colors.transparent,
        padding: .zero,
      ),
      css('ul, ol').styles(
        padding: .only(left: 1.5.rem),
        margin: .only(bottom: 1.rem),
      ),
      css('li').styles(margin: .only(bottom: 0.4.rem)),
      css('a').styles(
        color: colorSecondary,
        textDecoration: TextDecoration(line: .underline),
      ),
    ]),
  ];
}
