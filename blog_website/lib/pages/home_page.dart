import 'package:jaspr/jaspr.dart';

import '../sections/hero_section.dart';
import '../sections/timeline_section.dart';
import '../sections/skills_section.dart';
import '../sections/experiments_section.dart';
import '../sections/writing_section.dart';
import '../sections/contact_section.dart';

const _personJsonLd = '{'
    '"@context":"https://schema.org",'
    '"@type":"Person",'
    '"name":"Mayank Joshi",'
    '"url":"https://mayankjoshi.in",'
    '"jobTitle":"Senior Flutter Developer",'
    '"worksFor":{"@type":"Organization","name":"SpiceMoney"},'
    '"description":"Senior Flutter Developer with 12 years of experience. Mobile architect at SpiceMoney.",'
    '"sameAs":["https://github.com/consciousmayank","https://linkedin.com/in/mayankjoshi"],'
    '"knowsAbout":["Flutter","Dart","Mobile Development","Android","iOS","Web Development"]'
    '}';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      Document.head(
        children: [
          Component.element(tag: 'link', attributes: {'rel': 'canonical', 'href': 'https://mayankjoshi.in/'}),
          Component.element(tag: 'meta', attributes: {'property': 'og:type', 'content': 'profile'}),
          Component.element(tag: 'meta', attributes: {'property': 'og:url', 'content': 'https://mayankjoshi.in/'}),
          Component.element(tag: 'meta', attributes: {
            'property': 'og:title',
            'content': 'Mayank Joshi — Senior Flutter Developer · Mobile Architect',
          }),
          Component.element(tag: 'meta', attributes: {
            'property': 'og:description',
            'content': 'Senior Flutter Developer with 12 years of experience. '
                'Mobile architect at SpiceMoney. Writing about Flutter, Dart, AI, and '
                'cross-platform development.',
          }),
          Component.element(
            tag: 'script',
            attributes: {'type': 'application/ld+json'},
            children: [Component.text(_personJsonLd)],
          ),
        ],
      ),
      const HeroSection(),
      const TimelineSection(),
      const SkillsSection(),
      const ExperimentsSection(),
      const WritingSection(),
      const ContactSection(),
    ]);
  }
}
