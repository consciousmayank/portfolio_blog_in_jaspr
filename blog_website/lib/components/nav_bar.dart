import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../styles/theme.dart';

class NavBar extends StatelessComponent {
  final bool isDark;
  final void Function() onToggle;

  const NavBar({required this.isDark, required this.onToggle, super.key});

  @override
  Component build(BuildContext context) {
    final activePath = RouteState.of(context).location;

    return nav(classes: 'navbar', [
      div(classes: 'container navbar-inner', [
        Link(
          to: '/',
          child: span(classes: 'navbar-logo', [.text('MJ')]),
        ),
        div(classes: 'navbar-links', [
          for (final item in [
            (label: 'Home', path: '/'),
            (label: 'About', path: '/about'),
            (label: 'Blog', path: '/blog'),
            (label: 'Contact', path: '/contact'),
          ])
            Link(
              to: item.path,
              child: span(
                classes: activePath == item.path ? 'nav-link active' : 'nav-link',
                [.text(item.label)],
              ),
            ),
        ]),
        button(
          classes: 'theme-toggle btn btn-ghost',
          onClick: onToggle,
          [.text(isDark ? '☀ Light' : '☾ Dark')],
        ),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.navbar').styles(
      padding: .symmetric(vertical: 0.75.rem),
      border: .only(
        bottom: .solid(color: colorBorder, width: 1.px),
      ),
      backgroundColor: colorSurface,
    ),
    css('.navbar-inner').styles(
      display: .flex,
      alignItems: .center,
      justifyContent: .spaceBetween,
    ),
    css('.navbar-logo').styles(
      fontSize: 1.4.rem,
      fontWeight: .w700,
      color: colorPrimary,
      textDecoration: TextDecoration(line: .none),
      cursor: .pointer,
      fontFamily: const .list([FontFamily('Fira Code'), FontFamilies.monospace]),
    ),
    css('.navbar-links', [
      css('&').styles(display: .flex, alignItems: .center),
      css('.nav-link').styles(
        padding: .symmetric(horizontal: 0.85.rem, vertical: 0.4.rem),
        fontWeight: .w500,
        fontSize: 0.95.rem,
        color: colorText,
        textDecoration: TextDecoration(line: .none),
        radius: .all(.circular(4.px)),
        transition: Transition('background-color', duration: 150.ms, curve: .ease),
      ),
      css('.nav-link.active').styles(color: colorPrimary, fontWeight: .w700),
      css('.nav-link:hover').styles(color: colorPrimary),
    ]),
    css('.theme-toggle').styles(
      fontSize: 0.8.rem,
      padding: .symmetric(horizontal: 0.75.rem, vertical: 0.35.rem),
    ),
  ];
}
