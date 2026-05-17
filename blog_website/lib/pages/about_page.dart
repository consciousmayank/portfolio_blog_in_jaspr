import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/experience_card.dart';
import '../components/skill_chip.dart';

class AboutPage extends StatelessComponent {
  const AboutPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'container', [
      section(classes: 'section', [
        h1(classes: 'page-title', [.text('Resume')]),

        // ── Summary ───────────────────────────────────────────────────
        div(classes: 'resume-block', [
          h2(classes: 'section-title', [.text('Professional Summary')]),
          p([
            .text(
              'Senior Flutter Developer and Mobile Architect with 12 years of total experience '
              'and 8 years of dedicated Flutter expertise. Proven track record of delivering '
              'production-grade cross-platform applications for Android, iOS, and Web. '
              'Experienced in leading development teams, defining architecture standards, and '
              'integrating cloud-native backends. Currently building fintech products at scale '
              'at SpiceMoney.',
            ),
          ]),
        ]),

        // ── Core Competencies ────────────────────────────────────────
        div(classes: 'resume-block', [
          h2(classes: 'section-title', [.text('Core Competencies')]),
          div(classes: 'competency-chips', [
            for (final skill in [
              'Flutter SDK (8yr)',
              'Android Native',
              'BLoC',
              'Stacked',
              'GetX',
              'Riverpod',
              'MobX',
              'Firebase Analytics',
              'Firebase Crashlytics',
              'Firebase FCM',
              'FastAPI',
              'Next.js',
              'React.js',
              'Tailwind CSS',
              'Sentry',
              'Agile',
              'MVVM / Clean Architecture',
              'Unit & Integration Testing',
            ])
              SkillChip(skill),
          ]),
        ]),

        // ── Work Experience ───────────────────────────────────────────
        div(classes: 'resume-block', [
          h2(classes: 'section-title', [.text('Work Experience')]),
          const ExperienceCard(
            company: 'SpiceMoney',
            title: 'Assistant Manager, Mobile & Web Engineering',
            period: 'Mar 2024 – Present',
            location: 'Noida, Remote',
            highlights: [
              'Leading cross-platform mobile and web engineering for fintech products serving 10M+ users',
              'Architecting Flutter (Android/iOS/Web) and React.js solutions with microservices backend',
              'Defining code-review standards, CI/CD pipelines, and architecture patterns for a 12-person team',
              'Integrating AI-assisted development tooling to boost team velocity by 30%',
            ],
          ),
          const ExperienceCard(
            company: 'Chekk',
            title: 'Lead Flutter Developer',
            period: 'May 2022 – Jan 2024',
            location: 'Remote',
            highlights: [
              'Built and maintained a cross-platform identity-verification SDK used by 15+ partner apps',
              'Introduced BLoC + Clean Architecture, reducing bug regression rate by 40%',
              'Mentored 3 junior developers and conducted technical interviews',
              'Shipped iOS and Android builds on 2-week release cycles',
            ],
          ),
          const ExperienceCard(
            company: 'GeekTechnotonic Pvt Ltd',
            title: 'Lead Flutter Developer',
            period: 'Sep 2021 – May 2022',
            location: 'Dehradun',
            highlights: [
              'Led a 5-person Flutter team from zero to production launch in 4 months',
              'Implemented Riverpod state management and integrated Firebase Analytics & Crashlytics',
            ],
          ),
          const ExperienceCard(
            company: 'Embitel Technologies Pvt Ltd',
            title: 'Software Engineer, Android & Flutter',
            period: 'Jan 2014 – Sep 2021',
            location: 'Bangalore',
            highlights: [
              '7.5 years building native Android (Java/Kotlin) and Flutter applications for enterprise clients',
              'Delivered 10+ apps across automotive, retail, and logistics domains',
              'Transitioned fully to Flutter in 2017, becoming the team\'s Flutter champion',
              'Worked directly with clients across Europe, APAC, and North America',
            ],
          ),
        ]),

        // ── Education ─────────────────────────────────────────────────
        div(classes: 'resume-block', [
          h2(classes: 'section-title', [.text('Education')]),
          div(classes: 'edu-entry', [
            h3(classes: 'edu-degree', [.text('Master of Computer Applications (MCA)')]),
            p(classes: 'text-muted', [.text('Dehradun Institute of Technology | 2010 – 2013')]),
          ]),
          div(classes: 'edu-entry', [
            h3(classes: 'edu-degree', [.text('Bachelor of Computer Applications (BCA)')]),
            p(classes: 'text-muted', [
              .text('Amrapali Institute of Management and Technology | 2007 – 2010'),
            ]),
          ]),
        ]),

        // ── Download ─────────────────────────────────────────────────
        div(classes: 'resume-download', [
          a(href: '/assets/resume.pdf', [
            span(classes: 'btn btn-primary', [.text('Download Resume (PDF)')]),
          ]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.page-title').styles(
      fontSize: 2.rem,
      fontWeight: .w700,
      margin: .only(bottom: 2.rem),
    ),
    css('.resume-block').styles(margin: .only(bottom: 2.5.rem)),
    css('.competency-chips').styles(
      display: .flex,
      flexWrap: .wrap,
    ),
    css('.competency-chips .skill-chip').styles(margin: .only(right: 0.5.rem, bottom: 0.5.rem)),
    css('.edu-entry').styles(margin: .only(bottom: 1.25.rem)),
    css('.edu-degree').styles(
      fontSize: 1.rem,
      fontWeight: .w600,
      margin: .only(bottom: 0.2.rem),
    ),
    css('.resume-download').styles(margin: .only(top: 1.rem)),
  ];
}
