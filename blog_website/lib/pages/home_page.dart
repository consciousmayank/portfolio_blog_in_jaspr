import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/experience_card.dart';
import '../components/skill_chip.dart';
import '../styles/theme.dart';

class HomePage extends StatelessComponent {
  const HomePage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'container', [
      // ── Hero ──────────────────────────────────────────────────────────
      section(classes: 'section hero-section', [
        h1(classes: 'hero-name', [.text('Mayank Joshi')]),
        p(classes: 'hero-title', [
          .text('Senior Flutter Developer | Mobile Architect | Team Lead'),
        ]),
        p(classes: 'hero-location text-muted', [
          .text('Uttarakhand, India | Remote | IST (UTC+5:30)'),
        ]),
        div(classes: 'hero-cta', [
          Link(to: '/about', child: span(classes: 'btn btn-primary', [.text('View Resume')])),
          Link(to: '/blog', child: span(classes: 'btn btn-outline', [.text('Read Blog')])),
          Link(to: '/contact', child: span(classes: 'btn btn-ghost', [.text('Contact Me')])),
        ]),
      ]),

      // ── Skills ────────────────────────────────────────────────────────
      section(classes: 'section', [
        h2(classes: 'section-title', [.text('Core Skills')]),
        div(classes: 'skills-grid', [
          for (final skill in [
            'Flutter SDK (8yr)',
            'Android Native (Kotlin/Java)',
            'BLoC / Riverpod / GetX',
            'Firebase (Analytics / Crashlytics / FCM)',
            'Microservices Architecture',
            'AI Tool Integration',
          ])
            SkillChip(skill),
        ]),
      ]),

      // ── Featured Experience ───────────────────────────────────────────
      section(classes: 'section', [
        h2(classes: 'section-title', [.text('Experience')]),
        const ExperienceCard(
          company: 'SpiceMoney',
          title: 'Assistant Manager, Mobile & Web Engineering',
          period: 'Mar 2024 – Present',
          location: 'Noida, Remote',
          highlights: [
            'Leading cross-platform development for fintech products',
            'Architecting Flutter + React.js solutions for 10M+ users',
          ],
        ),
        const ExperienceCard(
          company: 'Chekk',
          title: 'Lead Flutter Developer',
          period: 'May 2022 – Jan 2024',
          location: 'Remote',
          highlights: [
            'Built identity verification SDK used across 15+ partner apps',
            'Introduced BLoC + Clean Architecture across the mobile team',
          ],
        ),
        const ExperienceCard(
          company: 'GeekTechnotonic Pvt Ltd',
          title: 'Lead Flutter Developer',
          period: 'Sep 2021 – May 2022',
          location: 'Dehradun',
          highlights: ['Led a 5-person Flutter team from 0 to production launch'],
        ),
        div(classes: 'view-full-resume', [
          Link(
            to: '/about',
            child: span(classes: 'btn btn-outline', [.text('View Full Resume →')]),
          ),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.hero-section', [
      css('&').styles(
        padding: .symmetric(vertical: 5.rem),
        display: .flex,
        flexDirection: .column,
        alignItems: .start,
      ),
      css('.hero-name').styles(
        fontSize: 3.rem,
        fontWeight: .w700,
        color: colorText,
        margin: .only(bottom: 0.5.rem),
      ),
      css('.hero-title').styles(
        fontSize: 1.2.rem,
        color: colorSecondary,
        fontWeight: .w500,
        margin: .only(bottom: 0.5.rem),
      ),
      css('.hero-location').styles(
        fontSize: 1.rem,
        margin: .only(bottom: 2.rem),
      ),
      css('.hero-cta').styles(
        display: .flex,
        flexWrap: .wrap,
      ),
      css('.hero-cta .btn').styles(margin: .only(right: 1.rem, bottom: 0.75.rem)),
    ]),
    css('.skills-grid').styles(
      display: .flex,
      flexWrap: .wrap,
    ),
    css('.skills-grid .skill-chip').styles(margin: .only(right: 0.5.rem, bottom: 0.5.rem)),
    css('.view-full-resume').styles(margin: .only(top: 1.5.rem)),
  ];
}
