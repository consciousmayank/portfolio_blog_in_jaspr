import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';

class ExperienceCard extends StatelessComponent {
  final String company;
  final String title;
  final String period;
  final String location;
  final List<String> highlights;

  const ExperienceCard({
    required this.company,
    required this.title,
    required this.period,
    required this.location,
    this.highlights = const [],
    super.key,
  });

  @override
  Component build(BuildContext context) {
    return div(classes: 'exp-card card', [
      div(classes: 'exp-header', [
        h3(classes: 'exp-company', [.text(company)]),
        span(classes: 'exp-period', [.text(period)]),
      ]),
      p(classes: 'exp-title', [.text(title)]),
      p(classes: 'exp-location text-muted', [.text(location)]),
      if (highlights.isNotEmpty)
        ul(classes: 'exp-highlights', [
          for (final h in highlights) li([.text(h)]),
        ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.exp-card', [
      css('&').styles(margin: .only(bottom: 1.5.rem)),
      css('.exp-header').styles(
        display: .flex,
        justifyContent: .spaceBetween,
        alignItems: .center,
        margin: .only(bottom: 0.25.rem),
      ),
      css('.exp-company').styles(
        fontSize: 1.1.rem,
        color: colorPrimary,
        margin: .zero,
      ),
      css('.exp-period').styles(
        fontSize: 0.85.rem,
        color: colorMuted,
      ),
      css('.exp-title').styles(
        fontWeight: .w600,
        margin: .only(bottom: 0.15.rem),
        fontSize: 0.95.rem,
      ),
      css('.exp-location').styles(
        fontSize: 0.85.rem,
        margin: .only(bottom: 0.5.rem),
      ),
      css('.exp-highlights').styles(
        margin: .only(top: 0.5.rem),
        padding: .only(left: 1.2.rem),
      ),
      css('.exp-highlights li').styles(
        fontSize: 0.9.rem,
        margin: .only(bottom: 0.25.rem),
      ),
    ]),
  ];
}
