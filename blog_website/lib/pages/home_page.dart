import 'package:jaspr/jaspr.dart';

import '../sections/hero_section.dart';
import '../sections/timeline_section.dart';
import '../sections/skills_section.dart';
import '../sections/experiments_section.dart';
import '../sections/writing_section.dart';
import '../sections/contact_section.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      const HeroSection(),
      const TimelineSection(),
      const SkillsSection(),
      const ExperimentsSection(),
      const WritingSection(),
      const ContactSection(),
    ]);
  }
}
