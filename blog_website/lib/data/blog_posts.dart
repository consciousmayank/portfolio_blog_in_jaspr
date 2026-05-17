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
