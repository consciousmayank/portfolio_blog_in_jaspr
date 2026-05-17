import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class ContactSection extends StatelessComponent {
  const ContactSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'contact', classes: 'ct', [
      div(classes: 'wrap', [
        div(classes: 'ct-grid', [
          _left(),
          _right(),
        ]),
        _footer(),
      ]),
    ]);
  }

  static Component _left() {
    return div([
      span(classes: 'eyebrow', [.text("06 — Let’s talk")]),
      h2([
        .text("Let’s build the "),
        em([.text('next')]),
        .text(' thing.'),
      ]),
      p(classes: 'lead', [
        .text(
          "Whether it’s a Flutter app you’ve outgrown, an AI tool you want done right, "
          "or a team that needs steady hands — I read every message I get.",
        ),
      ]),
      a(href: 'mailto:consciousmayank@gmail.com', classes: 'email', [
        span([.text('consciousmayank@gmail.com')]),
        RawText(
          '<svg class="arr" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" '
          'style="width:18px;height:18px">'
          '<path d="M7 17 17 7M9 7h8v8"/></svg>',
        ),
      ]),
    ]);
  }

  static Component _right() {
    return div([
      div(classes: 'ct-card', [
        h4([.text('// signal')]),
        div(classes: 'ct-list', [
          _row('Email', a(href: 'mailto:consciousmayank@gmail.com', classes: 'v', [.text('consciousmayank@gmail.com')])),
          _row(
            'LinkedIn',
            a(
              href: 'https://linkedin.com/in/mayank-joshi-2797b773',
              classes: 'v',
              attributes: {'target': '_blank'},
              [.text('/mayank-joshi-2797b773')],
            ),
          ),
          _row('Phone', span(classes: 'v', [.text('+91 96118 86339')])),
          _row('Located', span(classes: 'v', [.text('Uttarakhand, India · IST')])),
          _row(
            'Status',
            span(
              classes: 'v',
              styles: Styles(raw: {'color': 'var(--accent)'}),
              [.text('Open to senior & lead roles')],
            ),
          ),
        ]),
        div(classes: 'ct-availability', [
          div(classes: 't', [.text('// availability window')]),
          p([
            .text(
              "I take on one new engagement per quarter — currently with capacity for Q3 ’26. "
              'Remote-first, async-friendly, IST overlapping with EU & APAC.',
            ),
          ]),
        ]),
      ]),
    ]);
  }

  static Component _row(String label, Component value) {
    return div(classes: 'li', [
      span(classes: 'k', [.text(label)]),
      value,
    ]);
  }

  static Component _footer() {
    return footer(classes: 'footer', [
      span(classes: 'built', [
        span([.text('©')]),
        span([.text('2026 Mayank Joshi')]),
        span(styles: Styles(raw: {'margin': '0 6px'}), [.text('·')]),
        span([
          .text('built with '),
          span(classes: 'accent', [.text('Jaspr')]),
          .text(' & a lot of Dart'),
        ]),
      ]),
      span(classes: 'footer-links', [
        a(href: '#top', [.text('↑ top')]),
        a(href: 'https://github.com/consciousmayank', attributes: {'target': '_blank'}, [.text('github')]),
        a(href: 'https://linkedin.com/in/mayank-joshi-2797b773', attributes: {'target': '_blank'}, [.text('linkedin')]),
      ]),
    ]);
  }
}
