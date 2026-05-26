import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'components/theme_toggle.dart';
import 'pages/blog_post_page.dart';
import 'pages/home_page.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      Document.html(attributes: {
        'data-theme': 'editorial',
        'data-accent': 'plum',
        'data-density': 'comfy',
      }),
      Router(routes: [
        ShellRoute(
          builder: (context, state, child) => Component.fragment([
            _nav(),
            child,
          ]),
          routes: [
            Route(
              path: '/',
              title: 'Mayank Joshi — Senior Flutter Developer · Mobile Architect',
              settings: const RouteSettings(changeFreq: ChangeFreq.weekly, priority: 1.0),
              builder: (_, __) => const HomePage(),
            ),
            Route(
              path: '/blog/:slug',
              title: 'Mayank Joshi',
              settings: const RouteSettings(changeFreq: ChangeFreq.monthly, priority: 0.8),
              builder: (_, state) => BlogPostPage(slug: state.params['slug']!),
            ),
          ],
        ),
      ]),
    ]);
  }

  static Component _nav() {
    return header(classes: 'nav', [
      div(classes: 'wrap nav-inner', [
        a(href: '/', classes: 'nav-brand', [
          span(classes: 'glyph', [.text('M')]),
          span([
            .text('mayank'),
            span(styles: Styles(raw: {'color': 'var(--muted)'}), [.text('.joshi')]),
          ]),
          span(classes: 'status', [.text("Available · Q3 '26")]),
        ]),
        nav(classes: 'nav-links', [
          a(href: '/#timeline', [.text('Career')]),
          a(href: '/#skills', [.text('Skills')]),
          a(href: '/#experiments', [.text('My Lab')]),
          a(href: '/#writing', [.text('My Writings')]),
          a(href: '/#contact', [.text('Contact')]),
          const ThemeToggle(),
        ]),
      ]),
    ]);
  }
}
