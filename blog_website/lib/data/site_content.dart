class Role {
  final String company;
  final String title;
  final double start;
  final double end;
  final bool alt;

  const Role({
    required this.company,
    required this.title,
    required this.start,
    required this.end,
    this.alt = false,
  });
}

class CoreSkill {
  final String name;
  final int years;
  final int percent;
  final bool hot;

  const CoreSkill({
    required this.name,
    required this.years,
    required this.percent,
    this.hot = false,
  });
}

class ExperimentCard {
  final String code;
  final String status;
  final String title;
  final String body;
  final List<List<String>> demo;
  final String meta;
  final int span;

  const ExperimentCard({
    required this.code,
    required this.status,
    required this.title,
    required this.body,
    required this.demo,
    required this.meta,
    this.span = 4,
  });
}

const roles = [
  Role(company: 'Embitel', title: 'Software Engineer · Android & Flutter', start: 2014, end: 2021.7),
  Role(company: 'GeekTechnotonic', title: 'Lead Flutter Developer', start: 2021.7, end: 2022.4, alt: true),
  Role(company: 'Chekk', title: 'Lead Flutter Developer', start: 2022.4, end: 2024.05),
  Role(company: 'SpiceMoney', title: 'Asst. Manager — Mobile & Web', start: 2024.2, end: 2026),
];

const coreSkills = [
  CoreSkill(name: 'Flutter SDK', years: 8, percent: 95, hot: true),
  CoreSkill(name: 'Android (Kotlin/Java)', years: 11, percent: 88),
  CoreSkill(name: 'Dart', years: 8, percent: 92),
  CoreSkill(name: 'Next.js / React', years: 4, percent: 70),
  CoreSkill(name: 'FastAPI', years: 2, percent: 55),
  CoreSkill(name: 'Firebase', years: 7, percent: 82),
];

const stateManagement = ['BLoC', 'Stacked', 'GetX', 'Riverpod', 'MobX', 'Provider'];
const aiStack = ['Claude', 'GitHub Copilot', 'OpenAI Codex', 'Cursor', 'v0', 'prompt-driven specs'];
const architecture = [
  'Microservices-aligned',
  'Clean Architecture',
  'MVVM',
  'Repository pattern',
  'Feature modules',
  'Unit & integration testing',
];
const webOps = ['Tailwind CSS', 'Sentry', 'Vercel', 'PostgreSQL', 'REST + GraphQL', 'Stripe-like fintech APIs'];
const platforms = ['Android', 'iOS', 'Web (Flutter)', 'Web (Next.js)', 'PWA'];

const experiments = [
  ExperimentCard(
    code: '01',
    status: 'Shipping',
    title: 'AI-assisted PR review at SpiceMoney.',
    body:
        'An internal review companion that drafts checklists, flags risky diffs in Flutter / Next.js code, and writes a release-notes draft. Built in afternoons, used every working day.',
    demo: [
      ['pr-review --diff #482 --lens=flutter,a11y', 'pr'],
      ['✓ no blocking issues · 3 nits · 1 perf note', 'ok'],
      ['↳ suggests adding a golden test for new BLoC state', 'mu'],
      ['↳ release-notes draft attached', 'mu'],
    ],
    meta: 'Stack · Claude · GitHub Actions · Dart',
    span: 6,
  ),
  ExperimentCard(
    code: '02',
    status: 'Open',
    title: 'POS-in-a-day starter.',
    body:
        'An opinionated Flutter starter — clean architecture, BLoC, offline-first sync, PDF receipts. The thing I wish I’d had at GeekTechnotonic.',
    demo: [
      ['\$ pos-starter create my-cafe', 'pr'],
      ['scaffolding 14 feature modules…', 'mu'],
      ['✓ android · ios · web · desktop', 'ok'],
    ],
    meta: 'Stack · Flutter · Stacked · Hive',
    span: 6,
  ),
  ExperimentCard(
    code: '03',
    status: 'Concept',
    title: 'Crypto vault for fintech apps.',
    body:
        'Lessons learned from end-to-end-encrypting identity flows at Chekk, distilled into a tiny LibSodium wrapper any Flutter team can drop in.',
    demo: [
      ["import 'package:vault/vault.dart';", 'mu'],
      ['await Vault.seal(payload, theirPubKey)', 'pr'],
      ['// E2E in 3 lines · no ceremony', 'mu'],
    ],
    meta: 'Stack · Dart · LibSodium',
  ),
  ExperimentCard(
    code: '04',
    status: 'Shipping',
    title: 'Jaspr-rendered marketing site.',
    body:
        'This very portfolio — built in Jaspr (Flutter for the web). Same Dart, same patterns, same muscle memory. Static-rendered, fast, future-proof.',
    demo: [
      ['// jaspr build', 'mu'],
      ['compiling 14 components → main.dart.js', 'mu'],
      ['✓ 312 ms · 78 KB gzipped', 'ok'],
    ],
    meta: 'Stack · Jaspr · Dart · GitHub Pages',
  ),
];
