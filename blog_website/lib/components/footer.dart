import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Component build(BuildContext context) {
    return footer(classes: 'site-footer', [
      div(classes: 'container footer-inner', [
        div(classes: 'footer-links', [
          a(href: 'mailto:consciousmayank@gmail.com', [.text('consciousmayank@gmail.com')]),
          a(href: 'https://linkedin.com/in/mayank-joshi-2797b773', [.text('LinkedIn')]),
          a(href: 'https://github.com/mayankjoshi', [.text('GitHub')]),
        ]),
        p(classes: 'footer-copy text-muted', [.text('© 2025 Mayank Joshi. All rights reserved.')]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.site-footer').styles(
      padding: .symmetric(vertical: 2.rem),
      border: .only(
        top: .solid(color: colorBorder, width: 1.px),
      ),
    ),
    css('.footer-inner').styles(
      display: .flex,
      justifyContent: .spaceBetween,
      alignItems: .center,
      flexWrap: .wrap,
    ),
    css('.footer-links', [
      css('&').styles(
        display: .flex,
        flexWrap: .wrap,
      ),
      css('a').styles(
        color: colorMuted,
        margin: .only(right: 1.5.rem),
        fontSize: 0.9.rem,
        textDecoration: TextDecoration(line: .none),
      ),
      css('a:hover').styles(color: colorPrimary),
    ]),
    css('.footer-copy').styles(fontSize: 0.85.rem),
  ];
}
