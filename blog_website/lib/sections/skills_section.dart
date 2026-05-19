import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/site_content.dart';

class SkillsSection extends StatelessComponent {
  const SkillsSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'skills', classes: 'sk', [
      div(classes: 'wrap', [
        _head(),
        _grid(),
      ]),
    ]);
  }

  static Component _head() {
    return div(classes: 'sk-head', [
      span(classes: 'eyebrow', [.text('03 — The SKILLS')]),
      h2([
        .text('Depth in '),
        em([.text('one')]),
        .text(' codebase shipping three platforms — plus the tools that 10× a small team.'),
      ]),
      p([
        .text(
          'I optimise for boring, durable architecture and reach for AI tooling where it pays back in throughput. '
          "Below: where I’ve spent the hours, and what I reach for first.",
        ),
      ]),
    ]);
  }

  static Component _grid() {
    return div(classes: 'sk-grid', [
      _coreCard(),
      _aiCard(),
      _chipCard('// state management', stateManagement, 4),
      _chipCard('// architecture', architecture, 4),
      _chipCard('// platforms', platforms, 4),
      _chipCard('// web & ops', webOps, 12),
      _philosophy(),
    ]);
  }

  static Component _coreCard() {
    return div(
      classes: 'sk-card',
      styles: Styles(raw: {'grid-column': 'span 7'}),
      [
        div(classes: 'h', [
          span(classes: 'title', [.text('// core stack — by hours-in')]),
          span(classes: 'badge', [.text('12 yrs total')]),
        ]),
        for (var i = 0; i < coreSkills.length; i++) _skillRow(coreSkills[i], i),
      ],
    );
  }

  static Component _skillRow(CoreSkill s, int index) {
    return div(classes: 'sk-row', [
      div(classes: 'name', [.text(s.name)]),
      div(classes: 'bar', [
        div(
          classes: 'fill${s.hot ? ' accent' : ''}',
          styles: Styles(raw: {
            'width': '${s.percent}%',
            'animation-delay': '${index * 70}ms',
          }),
          [],
        ),
      ]),
      div(classes: 'yrs', [.text('${s.years} yrs')]),
    ]);
  }

  static Component _aiCard() {
    return div(
      classes: 'sk-card',
      styles: Styles(raw: {'grid-column': 'span 5'}),
      [
        div(classes: 'h', [
          span(classes: 'title', [.text('// AI in my loop')]),
          span(classes: 'badge', [.text('since 2023')]),
        ]),
        p(
          styles: Styles(raw: {
            'margin': '0 0 16px',
            'color': 'var(--ink-2)',
            'font-size': '14px',
            'line-height': '1.55',
          }),
          [
            .text(
              'I treat AI tools like a fast, eager pair-programmer. '
              'They scaffold, draft, test and review — I keep the taste and the architecture decisions.',
            ),
          ],
        ),
        _chips(aiStack),
      ],
    );
  }

  static Component _chipCard(String title, List<String> items, int colSpan) {
    return div(
      classes: 'sk-card',
      styles: Styles(raw: {'grid-column': 'span $colSpan'}),
      [
        div(classes: 'h', [
          span(classes: 'title', [.text(title)]),
        ]),
        _chips(items),
      ],
    );
  }

  static Component _chips(List<String> items) {
    return div(classes: 'sk-chips', [
      for (final c in items) span(classes: 'sk-chip', [.text(c)]),
    ]);
  }

  static Component _philosophy() {
    return div(classes: 'sk-philosophy', [
      div(classes: 'p', [
        span([.text('01.')]),
        .text(' One codebase. '),
        br(),
        .text('Three platforms. '),
        br(),
        .text('Zero magic.'),
      ]),
      div(classes: 'p', [
        span([.text('02.')]),
        .text(' AI drafts. '),
        br(),
        .text('I review. '),
        br(),
        .text("Tests don't lie."),
      ]),
      div(classes: 'p', [
        span([.text('03.')]),
        .text(' Boring architecture. '),
        br(),
        .text('Interesting product.'),
      ]),
    ]);
  }
}
