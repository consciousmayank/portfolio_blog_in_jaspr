import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/footer.dart';
import 'components/nav_bar.dart';
import 'data/blog_posts.dart';
import 'pages/about_page.dart';
import 'pages/blog_page.dart';
import 'pages/blog_post_page.dart';
import 'pages/contact_page.dart';
import 'pages/home_page.dart';

@client
class App extends StatefulComponent {
  const App({super.key});

  @override
  State<App> createState() => _AppState();

  @css
  static List<StyleRule> get styles => [
    css('.app').styles(
      display: .flex,
      minHeight: 100.vh,
      flexDirection: .column,
    ),
    css('.app.dark').styles(
      color: const Color('#e2e8f0'),
      backgroundColor: const Color('#0f1117'),
    ),
    css('.app.light').styles(
      color: const Color('#1a202c'),
      backgroundColor: const Color('#ffffff'),
    ),
    css('.app.light .card').styles(
      border: .symmetric(
        vertical: .solid(color: const Color('#cbd5e0'), width: 1.px),
        horizontal: .solid(color: const Color('#cbd5e0'), width: 1.px),
      ),
      backgroundColor: const Color('#f0f4f8'),
    ),
    css('.app.light .navbar').styles(
      border: .only(bottom: .solid(color: const Color('#e2e8f0'), width: 1.px)),
      backgroundColor: const Color('#f8fafc'),
    ),
    css('.app.light .site-footer').styles(
      border: .only(top: .solid(color: const Color('#e2e8f0'), width: 1.px)),
    ),
    css('.app.light .form-input').styles(
      border: .symmetric(
        vertical: .solid(color: const Color('#cbd5e0'), width: 1.px),
        horizontal: .solid(color: const Color('#cbd5e0'), width: 1.px),
      ),
      color: const Color('#1a202c'),
      backgroundColor: const Color('#ffffff'),
    ),
    css('.app.light .nav-link').styles(color: const Color('#1a202c')),
    css('.app.light .text-muted').styles(color: const Color('#718096')),
    // Grow main content area so footer stays at the bottom
    css('.app > .router-outlet, .app > div:not(.navbar):not(.site-footer)').styles(
      flex: Flex(grow: 1),
    ),
  ];
}

class _AppState extends State<App> {
  bool _isDark = true;

  @override
  Component build(BuildContext context) {
    return div(classes: 'app ${_isDark ? "dark" : "light"}', [
      Router(routes: [
        ShellRoute(
          builder: (context, state, child) => Component.fragment([
            NavBar(isDark: _isDark, onToggle: () => setState(() => _isDark = !_isDark)),
            child,
            const Footer(),
          ]),
          routes: [
            Route(path: '/', title: 'Mayank Joshi — Portfolio', builder: (_, __) => const HomePage()),
            Route(path: '/about', title: 'About — Mayank Joshi', builder: (_, __) => const AboutPage()),
            Route(path: '/blog', title: 'Blog — Mayank Joshi', builder: (_, __) => const BlogPage()),
            Route(path: '/contact', title: 'Contact — Mayank Joshi', builder: (_, __) => const ContactPage()),
            for (final post in blogPosts)
              Route(
                path: '/blog/${post.slug}',
                title: '${post.title} — Mayank Joshi',
                builder: (_, __) => BlogPostPage(post: post),
              ),
          ],
        ),
      ]),
    ]);
  }

}
