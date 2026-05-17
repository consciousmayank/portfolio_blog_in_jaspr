import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/hero_typewriter.dart';

class HeroSection extends StatelessComponent {
  const HeroSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'top', classes: 'hero', [
      div(classes: 'wrap', [
        div(classes: 'hero-grid', [
          _left(),
          _right(),
        ]),
        _aiStrip(),
      ]),
    ]);
  }

  static Component _left() {
    return div(classes: 'hero-left', [
      span(classes: 'eyebrow', [.text('Senior Flutter Developer · Mobile Architect')]),
      h1(classes: 'hero-name', [
        .text('Twelve years '),
        span(classes: 'amp', [.text('of')]),
        br(),
        .text('shipping mobile, '),
        span(classes: 'it', [.text('re­wired')]),
        br(),
        .text('for the AI era.'),
      ]),
      p(classes: 'hero-sub', [
        .text("I'm "),
        b([.text('Mayank Joshi')]),
        .text(
          ' — I lead mobile & web engineering at SpiceMoney from a quiet town in Uttarakhand. '
          "I've been writing Flutter since it had a beta sticker on it, and I think of AI as the fastest engineer I've ever paired with.",
        ),
      ]),
      div(classes: 'hero-meta', [
        span(classes: 'pill', [
          span(classes: 'dot', []),
          .text('Assistant Manager · SpiceMoney'),
        ]),
        span(classes: 'pill', [.text('Flutter · 8 yrs')]),
        span(classes: 'pill', [.text('IST (UTC+5:30)')]),
      ]),
      div(classes: 'hero-cta', [
        a(href: '#contact', classes: 'btn', [.text('Start a conversation →')]),
        a(href: '#experiments', classes: 'btn ghost', [.text('See the AI lab')]),
      ]),
    ]);
  }

  static Component _right() {
    return aside(classes: 'hero-right', [
      div(classes: 'hero-card', [
        div(classes: 'corner', [.text('// by the numbers')]),
        div(classes: 'stats', styles: Styles(raw: {'margin-top': '8px'}), [
          _stat('12', 'yrs', 'building software'),
          _stat('8', 'yrs', 'flutter, since v0.x'),
          _stat('5', null, 'teams led'),
          _stat('3', null, 'platforms, one codebase'),
        ]),
      ]),
      div(classes: 'hero-card now-card', [
        h4(styles: Styles(raw: {'font-size': '17px'}), [
          span(classes: 'dot', []),
          .text('currently'),
        ]),
        p(styles: Styles(raw: {'font-size': '23px'}), [
          .text('Shipping Flutter Web + Next.js surfaces for '),
          b(styles: Styles(raw: {'color': 'var(--ink)'}), [.text('spicemoney.com')]),
          .text(', and folding AI assistants deeper into our review & release loop.'),
        ]),
        div(classes: 'ticker', [
          span([.text('↳ pairing with')]),
          span(classes: 'v', [.text('Claude · Copilot · Codex')]),
        ]),
      ]),
    ]);
  }

  static Component _stat(String value, String? unit, String label) {
    return div(classes: 'stat', [
      div(classes: 'n', [
        .text(value),
        if (unit != null) span(classes: 'unit', [.text(unit)]),
      ]),
      div(classes: 'lbl', [.text(label)]),
    ]);
  }

  static Component _aiStrip() {
    return div(classes: 'ai-strip', [
      span(classes: 'bullet', []),
      span(classes: 'ai-label', [.text('~/mayank \$ ask me to')]),
      const HeroTypewriter(),
    ]);
  }
}
