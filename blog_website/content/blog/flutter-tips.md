---
title: "5 Flutter Tips I Wish I Knew Earlier"
date: "2025-06-15"
tags: ["flutter", "productivity", "dart"]
description: "Practical tips for Flutter developers from 8 years in the field."
---

# 5 Flutter Tips I Wish I Knew Earlier

Eight years of Flutter development leaves you with a lot of hard-won knowledge. Here are five things I wish someone had told me when I started.

## 1. Const Constructors Are Performance, Not Style

Adding `const` to your widgets isn't just about lint warnings. Const widgets are canonicalized by the Dart VM — the same const widget instance is reused across rebuilds. In large trees, this cuts rebuild time significantly. Make it a habit: if a widget has no dynamic data, prefix it with `const`.

```dart
// ❌ Rebuilds on every setState
Text('Mayank Joshi')

// ✅ Skips rebuild — same instance reused
const Text('Mayank Joshi')
```

## 2. Keys Are for List Items AND Stateful Siblings

Most developers know to add keys to list items. Few realize that when you have two stateful widgets of the same type as siblings (e.g., two `TextField` widgets side by side), Flutter may associate the wrong state with the wrong widget after a conditional rebuild. Use `ValueKey` or `UniqueKey` to be explicit.

## 3. Prefer `select` Over `watch` in Riverpod/BLoC

When you `watch` an entire state object, your widget rebuilds on ANY change to that object. When you `select` a specific field, the widget only rebuilds when that field changes. For complex screens with many state fields, `select` can reduce rebuilds by 80%+.

## 4. `RepaintBoundary` Surgically Stops Expensive Repaints

Animations and `CustomPainter` widgets trigger repaints on their entire subtree. Wrapping a frequently-animating widget in `RepaintBoundary` isolates it so the rest of the tree isn't repainted on every frame. Essential for complex UIs.

## 5. Test Your Navigation Flow with Integration Tests

Unit tests are great, but navigation bugs are usually only caught manually. Invest in Flutter integration tests (`package:integration_test`) that walk through your app's core user journeys end-to-end. The upfront cost is 30 minutes per flow; the payoff is catching regressions before your users do.

---

That's the list. Small habits, big impact. If you have tips of your own, I'd love to hear them — reach out via the contact page.
