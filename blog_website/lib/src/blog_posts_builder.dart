import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:build/build.dart';
// ignore: depend_on_referenced_packages
import 'package:yaml/yaml.dart';

Builder blogPostsBuilder(BuilderOptions options) => _BlogPostsBuilder();

class _BlogPostsBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': ['data/blog_posts.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final posts = <_Post>[];

    // Use dart:io directly so we don't need content/ in build.yaml sources
    // (which would break jaspr_builder's intermediate cache lookups).
    final contentDir = Directory('content/blog');
    if (contentDir.existsSync()) {
      for (final entity in contentDir.listSync()..sort((a, b) => a.path.compareTo(b.path))) {
        if (entity is File && entity.path.endsWith('.md')) {
          final raw = entity.readAsStringSync();
          final slug = entity.uri.pathSegments.last.replaceFirst('.md', '');
          posts.add(_parsePost(slug, raw));
        }
      }
    }

    posts.sort((a, b) => b.date.compareTo(a.date));

    final output = AssetId(buildStep.inputId.package, 'lib/data/blog_posts.dart');
    await buildStep.writeAsString(output, _generate(posts));
  }

  _Post _parsePost(String slug, String raw) {
    const sep = '---\n';
    if (!raw.startsWith(sep)) {
      return _Post(slug: slug, title: slug, date: '', tags: [], description: '', body: raw.trim());
    }
    final end = raw.indexOf('\n---\n', sep.length);
    if (end == -1) {
      return _Post(slug: slug, title: slug, date: '', tags: [], description: '', body: raw.trim());
    }

    final fm = loadYaml(raw.substring(sep.length, end)) as YamlMap;
    final body = raw.substring(end + 5).trimLeft();

    return _Post(
      slug: slug,
      title: fm['title']?.toString() ?? slug,
      date: fm['date']?.toString() ?? '',
      tags: (fm['tags'] as YamlList?)?.map((e) => e.toString()).toList() ?? [],
      description: fm['description']?.toString() ?? '',
      body: body,
    );
  }

  String _generate(List<_Post> posts) {
    final buf = StringBuffer()
      ..writeln('// GENERATED FILE — do not edit by hand.')
      ..writeln('// Source: content/blog/*.md')
      ..writeln('// Regenerate: dart run build_runner build')
      ..writeln();

    buf
      ..writeln('class BlogPost {')
      ..writeln('  final String slug;')
      ..writeln('  final String title;')
      ..writeln('  final String date;')
      ..writeln('  final List<String> tags;')
      ..writeln('  final String description;')
      ..writeln('  final String contentMarkdown;')
      ..writeln()
      ..writeln('  const BlogPost({')
      ..writeln('    required this.slug,')
      ..writeln('    required this.title,')
      ..writeln('    required this.date,')
      ..writeln('    required this.tags,')
      ..writeln('    required this.description,')
      ..writeln('    required this.contentMarkdown,')
      ..writeln('  });')
      ..writeln('}')
      ..writeln()
      ..writeln('const blogPosts = [');

    for (final post in posts) {
      final tagsLit = post.tags.map(_str).join(', ');
      buf
        ..writeln('  BlogPost(')
        ..writeln("    slug: '${post.slug}',")
        ..writeln('    title: ${_str(post.title)},')
        ..writeln("    date: '${post.date}',")
        ..writeln('    tags: [$tagsLit],')
        ..writeln('    description: ${_str(post.description)},')
        // json.encode produces a valid Dart string literal with all escapes handled
        ..writeln('    contentMarkdown: ${json.encode(post.body)},')
        ..writeln('  ),');
    }

    buf.writeln('];');
    return buf.toString();
  }

  // Produces a Dart string literal, choosing quote style to avoid escaping.
  String _str(String s) {
    if (!s.contains("'")) return "'$s'";
    if (!s.contains('"')) return '"$s"';
    return json.encode(s);
  }
}

class _Post {
  final String slug, title, date, description, body;
  final List<String> tags;

  const _Post({
    required this.slug,
    required this.title,
    required this.date,
    required this.tags,
    required this.description,
    required this.body,
  });
}
