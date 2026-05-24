import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/api_client.dart';

class ExperimentsSection extends StatelessComponent {
  const ExperimentsSection({required this.experiments, super.key});

  final List<ExperimentCard> experiments;

  @override
  Component build(BuildContext context) {
    return section(id: 'experiments', classes: 'ex', [
      div(classes: 'wrap', [
        _head(),
        _grid(),
      ]),
    ]);
  }

  static Component _head() {
    return div(classes: 'ex-head', [
      div([
        span(classes: 'eyebrow', [.text('04 — The AI lab')]),
        h2([
          .text('Small bets where '),
          em([.text('AI')]),
          .text(' meets the boring craft of shipping software.'),
        ]),
      ]),
    ]);
  }

  Component _grid() {
    return div(classes: 'ex-grid', [
      for (final c in experiments) _card(c),
    ]);
  }

  static Component _card(ExperimentCard c) {
    return article(
      classes: 'ex-card',
      styles: Styles(raw: {'grid-column': 'span ${c.span}'}),
      [
        div(classes: 'head', [
          span([.text('experiment / ${c.code}')]),
          span(classes: 'status', [
            span(classes: 'dot', []),
            .text(c.status),
          ]),
        ]),
        div(classes: 'body', [
          h3([.text(c.title)]),
          p([.text(c.body)]),
        ]),
        div(classes: 'demo', [
          for (final row in c.demo)
            span(classes: 'ln ${row[1]}', [
              if (row[1] == 'pr')
                span(styles: Styles(raw: {'color': 'var(--muted)'}), [.text('\$ ')]),
              .text(row[0]),
            ]),
        ]),
        div(classes: 'foot', [
          span([.text(c.meta)]),
          a(href: '#contact', [.text('case-note →')]),
        ]),
      ],
    );
  }
}
