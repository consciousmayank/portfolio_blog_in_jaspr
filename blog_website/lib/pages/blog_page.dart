import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/blog_card.dart';
import '../data/blog_posts.dart';

class BlogPage extends StatelessComponent {
  const BlogPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'container', [
      section(classes: 'section', [
        h1(classes: 'page-title', [.text('Blog')]),
        p(classes: 'text-muted', [
          .text('Thoughts on Flutter, mobile architecture, and engineering leadership.'),
        ]),
        div(classes: 'blog-grid', [
          for (final post in blogPosts)
            BlogCard(
              title: post.title,
              date: post.date,
              tags: post.tags,
              excerpt: post.description,
              slug: post.slug,
            ),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.blog-grid').styles(
      display: .flex,
      flexDirection: .column,
      margin: .only(top: 2.rem),
    ),
    css('.blog-grid .blog-card').styles(margin: .only(bottom: 1.5.rem)),
  ];
}
