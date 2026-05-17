import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';

class SkillChip extends StatelessComponent {
  final String label;
  const SkillChip(this.label, {super.key});

  @override
  Component build(BuildContext context) {
    return span(classes: 'skill-chip', [.text(label)]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.skill-chip').styles(
      display: .inlineFlex,
      alignItems: .center,
      padding: .symmetric(horizontal: 0.75.rem, vertical: 0.3.rem),
      radius: .all(.circular(4.px)),
      fontSize: 0.8.rem,
      fontFamily: const .list([FontFamily('Fira Code'), FontFamilies.monospace]),
      fontWeight: .w500,
      border: .symmetric(
        vertical: .solid(color: colorSecondary, width: 1.px),
        horizontal: .solid(color: colorSecondary, width: 1.px),
      ),
      color: colorSecondary,
      backgroundColor: Colors.transparent,
    ),
  ];
}
