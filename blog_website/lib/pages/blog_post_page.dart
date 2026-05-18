import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:markdown/markdown.dart' as md;

import '../data/blog_posts.dart';

class BlogPostPage extends StatelessComponent {
  final BlogPost post;
  const BlogPostPage({required this.post, super.key});

  @override
  Component build(BuildContext context) {
    final postUrl = 'https://mayankjoshi.in/blog/${post.slug}';
    final htmlBody = md.markdownToHtml(
      post.contentMarkdown,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    return Component.fragment([
      Document.head(
        title: '${post.title} — Mayank Joshi',
        meta: {'description': post.description},
        children: [
          Component.element(tag: 'meta', attributes: {'property': 'og:type', 'content': 'article'}),
          Component.element(tag: 'meta', attributes: {'property': 'og:title', 'content': post.title}),
          Component.element(tag: 'meta', attributes: {'property': 'og:description', 'content': post.description}),
          Component.element(tag: 'meta', attributes: {'property': 'og:url', 'content': postUrl}),
          Component.element(tag: 'meta', attributes: {'name': 'twitter:title', 'content': post.title}),
          Component.element(tag: 'meta', attributes: {'name': 'twitter:description', 'content': post.description}),
          Component.element(tag: 'link', attributes: {'rel': 'canonical', 'href': postUrl}),
          Component.element(
            tag: 'script',
            attributes: {'type': 'application/ld+json'},
            children: [Component.text(_blogPostingJsonLd(postUrl))],
          ),
        ],
      ),
      section(classes: 'blog-post', [
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
      ]),
    ]);
  }

  String _blogPostingJsonLd(String postUrl) {
    final safeTitle = post.title.replaceAll('"', '\\"');
    final safeDesc = post.description.replaceAll('"', '\\"');
    final keywords = post.tags.join(', ');
    return '{'
        '"@context":"https://schema.org",'
        '"@type":"BlogPosting",'
        '"headline":"$safeTitle",'
        '"description":"$safeDesc",'
        '"datePublished":"${post.date}",'
        '"dateModified":"${post.date}",'
        '"url":"$postUrl",'
        '"keywords":"$keywords",'
        '"author":{'
        '"@type":"Person",'
        '"name":"Mayank Joshi",'
        '"url":"https://mayankjoshi.in",'
        '"jobTitle":"Senior Flutter Developer",'
        '"sameAs":["https://github.com/consciousmayank","https://linkedin.com/in/mayankjoshi"]'
        '},'
        '"publisher":{"@type":"Person","name":"Mayank Joshi","url":"https://mayankjoshi.in"}'
        '}';
  }
}
