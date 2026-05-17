import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../data/site_content.dart';

const _yStart = 2014;
const _yEnd = 2026;
const _span = _yEnd - _yStart;

String _pctFrom(double y) => '${((y - _yStart) / _span) * 100}%';
String _pctWidth(double start, double end) => '${((end - start) / _span) * 100}%';

class TimelineSection extends StatelessComponent {
  const TimelineSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'timeline', classes: 'tl', [
      div(classes: 'wrap', [
        _head(),
        _chart(),
        _callouts(),
      ]),
    ]);
  }

  static Component _head() {
    return div(classes: 'tl-head', [
      div([
        span(classes: 'eyebrow', [.text('02 — The 12-year arc')]),
        h2([
          .text('From Android Studio betas to '),
          em([.text('AI-augmented')]),
          .text(' release trains.'),
        ]),
      ]),
      div(classes: 'legend', [
        span([
          span(classes: 'sw', styles: Styles(raw: {'background': 'var(--ink)'}), []),
          .text('Tenure'),
        ]),
        span([
          span(
            classes: 'sw',
            styles: Styles(raw: {'background': 'var(--bg-3)', 'border': '1px solid var(--line)'}),
            [],
          ),
          .text('Lead role'),
        ]),
        span([
          span(
            classes: 'sw',
            styles: Styles(raw: {'border-top': '1px dashed var(--accent)', 'background': 'var(--accent-soft)'}),
            [],
          ),
          .text('AI in workflow'),
        ]),
      ]),
    ]);
  }

  static Component _chart() {
    final years = List.generate(_yEnd - _yStart, (idx) => _yStart + idx);

    return div(classes: 'tl-chart', [
      div(classes: 'tl-years', [
        for (var i = 0; i < years.length; i++)
          div(
            classes: 'tl-yr',
            attributes: {'data-now': years[i] >= _yEnd - 1 ? 'true' : 'false'},
            [
              if (i % 2 == 0) span(classes: 'yr-lbl', [.text('${years[i]}')]),
            ],
          ),
        span(
          classes: 'yr-lbl',
          styles: Styles(raw: {'position': 'absolute', 'right': '-12px', 'bottom': '-28px'}),
          [.text("'26")],
        ),
      ]),
      div(classes: 'tl-rows', [
        for (final r in roles) ...[
          div(classes: 'tl-role-label', [.text(r.company)]),
          div(classes: 'tl-track', [
            div(
              classes: 'tl-bar${r.alt ? ' alt' : ''}',
              styles: Styles(raw: {'left': _pctFrom(r.start), 'width': _pctWidth(r.start, r.end)}),
              attributes: {'title': '${r.title} · ${r.start.toStringAsFixed(0)}–${r.end.toStringAsFixed(0)}'},
              [.text(r.title)],
            ),
          ]),
        ],
        div(
          classes: 'tl-role-label',
          styles: Styles(raw: {'color': 'var(--accent)'}),
          [.text('AI in loop')],
        ),
        div(styles: Styles(raw: {'position': 'relative'}), [
          div(
            classes: 'tl-overlay',
            styles: Styles(raw: {
              'margin-left': _pctFrom(2023),
              'width': _pctWidth(2023, 2026),
              'margin-top': '0',
            }),
            [.text('Copilot · Claude · Codex')],
          ),
        ]),
      ]),
    ]);
  }

  static Component _callouts() {
    return div(classes: 'tl-callouts', [
      div(classes: 'card', [
        div(classes: 'yr', [.text('2014 — 2021')]),
        h4([.text('Android-native foundations.')]),
        p([
          .text(
            'Shipped retail & enterprise apps across BMMI, Tata Trent and Excite. '
            'Learned the boring, important parts: release cycles, debugging in the dark, supporting customers in production.',
          ),
        ]),
      ]),
      div(classes: 'card', [
        div(classes: 'yr', [.text('2021 — 2024')]),
        h4([.text('Leading Flutter teams.')]),
        p([
          .text(
            'Architected a Flutter POS/inventory platform with PDF reports, then led a 3-person team '
            "porting Chekk's identity verification stack to Flutter with LibSodium crypto end-to-end.",
          ),
        ]),
      ]),
      div(
        classes: 'card',
        styles: Styles(raw: {'border-color': 'var(--accent)'}),
        [
          div(
            classes: 'yr',
            styles: Styles(raw: {'color': 'var(--accent)'}),
            [.text('2024 — now')],
          ),
          h4([.text('AI-augmented delivery.')]),
          p([
            .text(
              'At SpiceMoney, I run Flutter Web + Next.js delivery and quietly fold AI tools '
              'into spec → code → review → ship — measured in throughput, not vibes.',
            ),
          ]),
        ],
      ),
    ]);
  }
}
