import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:markdown/markdown.dart' as md;

import '../data/blog_posts.dart';

class BlogPostPage extends StatelessComponent {
  final BlogPost post;
  const BlogPostPage({required this.post, super.key});

  @override
  Component build(BuildContext context) {
    final htmlBody = md.markdownToHtml(
      post.contentMarkdown,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    return section(classes: 'blog-post', [
      div(classes: 'wrap', [
        div(classes: 'post-back', [
          a(href: '/', [.text('← Back to home')]),
        ]),
        Component.element(tag: 'article', children: [
          header(classes: 'post-header', [
            h1(classes: 'post-title', [.text(post.title)]),
            div(classes: 'post-date', [.text(post.date)]),
            div(classes: 'post-tags', [
              for (final tag in post.tags)
                span(classes: 'sk-chip', [.text(tag)]),
            ]),
          ]),
          div(classes: 'post-body', [RawText(htmlBody)]),
        ]),
      ]),
    ]);
  }
}
