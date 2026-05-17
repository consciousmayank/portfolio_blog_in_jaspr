// GENERATED FILE — do not edit by hand.
// Source: content/blog/*.md
// Regenerate: dart run build_runner build

class BlogPost {
  final String slug;
  final String title;
  final String date;
  final List<String> tags;
  final String description;
  final String contentMarkdown;

  const BlogPost({
    required this.slug,
    required this.title,
    required this.date,
    required this.tags,
    required this.description,
    required this.contentMarkdown,
  });
}

const blogPosts = [
  BlogPost(
    slug: 'the-road-to-io-2026-the-pure-impeller-era-and-standalone-ui-ecosystem',
    title: 'The Road to I/O 2026: The Pure Impeller Era and Standalone UI Ecosystem',
    date: '2026-05-17',
    tags: ['flutter', 'dart', 'google-io', 'ai', 'impeller', 'wasm', 'mcp'],
    description: 'A comprehensive review of the historical shifts hit by the Flutter 3.44 branch right before Google I/O 2026—exploring Agent Skills, MCP, Material/Cupertino decoupling, and Wasm-first performance.',
    contentMarkdown: "With the massive **Google I/O 2026** conference kicking off this Tuesday (May 19), the past 24 hours have been dominated by the community finalizing their setups for the groundbreaking features of the **Flutter 3.44 branch**. Here is your definitive summary of the biggest architectural shifts and announcements from the past week.\n\n----------\n\n## The Week in Review (May 11 – May 17, 2026)\n\n### Standardizing the AI-Driven Framework Ecosystem\n\n#### 1. The Dawn of \"Agent Skills\" & MCP Integration\n\nThe most heavily discussed announcement this week was the debut of **Agent Skills for Dart and Flutter**. Paired with the open **Model Context Protocol (MCP)**, this feature gives AI coding assistants real-time, zero-config access to local Dart SDK analyzers. Rather than pasting snippets back and forth into a browser tab, engineers are now using local LLMs on their development machines to run native tests, refactor deep widget structures, and check type safety locally with complete semantic accuracy.\n\n#### 2. The Material & Cupertino \"Decoupling\" Solidifies\n\nWe tracked the transition steps for Flutter's major architectural shift: pulling the Material and Cupertino design libraries completely out of the core `flutter/flutter` repository. Moving forward into the 3.44 branch lifecycle, these are officially treated as unopinionated, independently versioned standalone packages on `pub.dev`. This has turned the underlying engine into a lightweight, high-performance **Universal Rendering Canvas**.\n\n#### 3. Performance Baseline: Pure Impeller & Wasm Defaults\n\nOn the tooling front, Wednesday's update highlighted that the **Flutter DevTools** suite is now completely compiled down to **WasmGC** by default, removing over 200ms of lag during telemetry parsing. Simultaneously, the complete removal of the legacy Skia engine on Android 10+ means the **Impeller Vulkan backend** is officially the unified standard for modern mobile platforms, boosting startup-to-interaction times across the board.\n\n#### 4. Google I/O Previews: Interpreted Bytecode Leaks\n\nPre-conference schedule leaks have essentially confirmed that Google will be highlighting **interpreted bytecode** runtimes for Dart. This foundational tech allows for \"Ephemeral Experiences\" — meaning AI agents can stream temporary design patches and functional UI surfaces instantly over the air without forcing users through a rigid App Store or Play Store review cycle.\n\n----------\n\n## Senior Dev's Take\n\n*\"Looking back at the past seven days, the biggest takeaway is that Flutter has aggressively outgrown its identity as just a 'mobile framework.' By standardising on **MCP** and open AI protocols, the team has effectively future-proofed our codebases for the next decade of development.\n\nIf you haven't checked your existing project pipelines yet, take an hour this Sunday evening to prepare. Run a dry run using **Wasm compilation** on your web modules and test your pluggable modules against the new standalone `material_ui` package path. The pace of app architecture is going to change permanently once the Google I/O keynote drops on Tuesday, and having your environment completely clean is the best advantage you can give yourself.\"*\n\n----------\n\nFor a practical breakdown of how this new tooling ecosystem behaves under the hood, check out the community deep-dive on [Installing and Using Agent Skills for Dart & Flutter](https://www.youtube.com/watch?v=yX_stItg0lI). This video offers an excellent walkthrough of setting up Agent Skills locally to optimize workflows right before the Google I/O updates go live.\n",
  ),
  BlogPost(
    slug: 'flutter-tips',
    title: '5 Flutter Tips I Wish I Knew Earlier',
    date: '2025-06-15',
    tags: ['flutter', 'productivity', 'dart'],
    description: 'Practical tips for Flutter developers from 8 years in the field.',
    contentMarkdown: "# 5 Flutter Tips I Wish I Knew Earlier\n\nEight years of Flutter development leaves you with a lot of hard-won knowledge. Here are five things I wish someone had told me when I started.\n\n## 1. Const Constructors Are Performance, Not Style\n\nAdding `const` to your widgets isn't just about lint warnings. Const widgets are canonicalized by the Dart VM — the same const widget instance is reused across rebuilds. In large trees, this cuts rebuild time significantly. Make it a habit: if a widget has no dynamic data, prefix it with `const`.\n\n```dart\n// ❌ Rebuilds on every setState\nText('Mayank Joshi')\n\n// ✅ Skips rebuild — same instance reused\nconst Text('Mayank Joshi')\n```\n\n## 2. Keys Are for List Items AND Stateful Siblings\n\nMost developers know to add keys to list items. Few realize that when you have two stateful widgets of the same type as siblings (e.g., two `TextField` widgets side by side), Flutter may associate the wrong state with the wrong widget after a conditional rebuild. Use `ValueKey` or `UniqueKey` to be explicit.\n\n## 3. Prefer `select` Over `watch` in Riverpod/BLoC\n\nWhen you `watch` an entire state object, your widget rebuilds on ANY change to that object. When you `select` a specific field, the widget only rebuilds when that field changes. For complex screens with many state fields, `select` can reduce rebuilds by 80%+.\n\n## 4. `RepaintBoundary` Surgically Stops Expensive Repaints\n\nAnimations and `CustomPainter` widgets trigger repaints on their entire subtree. Wrapping a frequently-animating widget in `RepaintBoundary` isolates it so the rest of the tree isn't repainted on every frame. Essential for complex UIs.\n\n## 5. Test Your Navigation Flow with Integration Tests\n\nUnit tests are great, but navigation bugs are usually only caught manually. Invest in Flutter integration tests (`package:integration_test`) that walk through your app's core user journeys end-to-end. The upfront cost is 30 minutes per flow; the payoff is catching regressions before your users do.\n\n---\n\nThat's the list. Small habits, big impact. If you have tips of your own, I'd love to hear them — reach out via the contact page.\n",
  ),
  BlogPost(
    slug: 'hello-world',
    title: 'Hello World',
    date: '2025-06-01',
    tags: ['flutter', 'dart'],
    description: 'Welcome to my developer blog — where I share what I learn building cross-platform apps.',
    contentMarkdown: "# Hello World\n\nWelcome to my blog! I'm Mayank Joshi — a Senior Flutter Developer with 12 years of total experience and 8 years of dedicated Flutter expertise. After years of building mobile and web apps across industries, I decided it was time to document what I know and share it with the community.\n\n## Why I'm Writing\n\nI've learned a tremendous amount from other developers' blogs, open-source projects, and Stack Overflow threads. This blog is my way of giving back. I'll be writing about Flutter, Dart, mobile architecture, team leadership, and anything else I encounter in the day-to-day reality of software engineering.\n\n## What to Expect\n\n- Deep-dives into Flutter architecture patterns (BLoC, Riverpod, Clean Architecture)\n- Lessons learned from leading development teams at scale\n- Practical tips for cross-platform development on Android, iOS, and Web\n- Thoughts on AI-assisted development workflows\n\nThanks for stopping by. The first real post is already live — see you there.\n",
  ),
];
