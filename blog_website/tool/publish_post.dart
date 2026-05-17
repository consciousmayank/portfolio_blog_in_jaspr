// Run from blog_website/: dart run tool/publish_post.dart
//
// Reads template_blog.md, generates a slug + today's date, writes the post
// to content/blog/<slug>.md, resets the template, then regenerates blog_posts.dart.

import 'dart:io';

void main() {
  final template = File('template_blog.md');

  if (!template.existsSync()) {
    _exit('template_blog.md not found. Run from the blog_website/ directory.');
  }

  final raw = template.readAsStringSync();

  // ── Parse frontmatter ────────────────────────────────────────────────────
  if (!raw.startsWith('---\n')) {
    _exit('template_blog.md must start with --- frontmatter.');
  }
  final fmEnd = raw.indexOf('\n---\n', 4);
  if (fmEnd == -1) {
    _exit('Could not find closing --- in frontmatter.');
  }

  final fmRaw = raw.substring(4, fmEnd);
  final body = raw.substring(fmEnd + 5).trim();

  if (body.isEmpty || body == 'Write your post content here in Markdown.') {
    _exit('Post body is empty. Write your content in template_blog.md first.');
  }

  final fm = _parseFrontmatter(fmRaw);

  final title = fm['title'] ?? '';
  final tags = fm['tags'] ?? '[]';
  final description = fm['description'] ?? '';

  if (title.isEmpty || title == 'Your Post Title Here') {
    _exit('Set a real title in the template frontmatter.');
  }
  if (description.isEmpty || description.contains('one-sentence description')) {
    _exit('Set a real description in the template frontmatter.');
  }

  // ── Generate slug & date ─────────────────────────────────────────────────
  final slug = _toSlug(title);
  final date = _today();

  // ── Build output path ────────────────────────────────────────────────────
  final outFile = File('content/blog/$slug.md');
  if (outFile.existsSync()) {
    _exit('content/blog/$slug.md already exists. Rename the post or delete the old file.');
  }

  // ── Write the real post ──────────────────────────────────────────────────
  final post = '''---
title: ${_quoteIfNeeded(title)}
date: "$date"
tags: $tags
description: ${_quoteIfNeeded(description)}
---

$body
''';

  outFile.writeAsStringSync(post);
  print('✓ Created content/blog/$slug.md');

  // ── Reset template ───────────────────────────────────────────────────────
  template.writeAsStringSync('''---
title: "Your Post Title Here"
tags: ["flutter", "dart"]
description: "A one-sentence description shown on the blog listing page."
---

Write your post content here in Markdown.
''');
  print('✓ Reset template_blog.md');

  // ── Regenerate blog_posts.dart ───────────────────────────────────────────
  print('⟳ Running build_runner...');
  final result = Process.runSync(
    'dart',
    ['run', 'build_runner', 'build'],
    runInShell: true,
  );

  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    _exit('build_runner failed (exit ${result.exitCode}).');
  }

  print('✓ blog_posts.dart regenerated');
  print('');
  print('Done! Your post will be live at: /blog/$slug');
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Map<String, String> _parseFrontmatter(String fm) {
  final result = <String, String>{};
  // Handles both  key: value  and  key: "value"  and  key: [...]
  final lineRe = RegExp(r'^(\w+):\s*(.+)$');
  for (final line in fm.split('\n')) {
    final m = lineRe.firstMatch(line.trim());
    if (m != null) result[m.group(1)!] = m.group(2)!.trim();
  }
  return result;
}

String _toSlug(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r"[''']"), '')        // smart/straight apostrophes
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // strip non-alphanumeric
      .trim()
      .replaceAll(RegExp(r'\s+'), '-')          // spaces → hyphens
      .replaceAll(RegExp(r'-{2,}'), '-');        // collapse double hyphens
}

String _today() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

// Wrap in double quotes if the string contains single quotes, otherwise single.
String _quoteIfNeeded(String s) {
  // Already quoted in template — strip outer quotes first
  var v = s;
  if ((v.startsWith('"') && v.endsWith('"')) ||
      (v.startsWith("'") && v.endsWith("'"))) {
    v = v.substring(1, v.length - 1);
  }
  if (v.contains('"')) return "'$v'";
  return '"$v"';
}

Never _exit(String message) {
  stderr.writeln('Error: $message');
  exit(1);
}
