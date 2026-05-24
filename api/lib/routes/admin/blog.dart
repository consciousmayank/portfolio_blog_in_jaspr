import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../db/pool.dart';

Router adminBlogRoutes(Db db) {
  final r = Router();

  r.get('/', (Request req) async {
    final rows = await db.pool.execute(Sql.named('''
      SELECT p.id, p.slug, p.title, p.date, p.description, p.cover_image_path,
             p.published, p.sort_index, p.body_markdown,
             COALESCE(array_agg(t.tag) FILTER (WHERE t.tag IS NOT NULL), '{}') AS tags
        FROM blog_posts p
        LEFT JOIN blog_post_tags t ON t.post_id = p.id
       GROUP BY p.id
       ORDER BY p.date DESC, p.id DESC
    '''));
    return Response.ok(jsonEncode(rows.map(_row).toList()), headers: _json);
  });

  r.get('/<slug>', (Request req, String slug) async {
    final rows = await db.pool.execute(
      Sql.named('''
        SELECT p.id, p.slug, p.title, p.date, p.description, p.cover_image_path,
               p.published, p.sort_index, p.body_markdown,
               COALESCE(array_agg(t.tag) FILTER (WHERE t.tag IS NOT NULL), '{}') AS tags
          FROM blog_posts p
          LEFT JOIN blog_post_tags t ON t.post_id = p.id
         WHERE p.slug = @s
         GROUP BY p.id
      '''),
      parameters: {'s': slug},
    );
    if (rows.isEmpty) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: _json);
    return Response.ok(jsonEncode(_row(rows.first)), headers: _json);
  });

  r.post('/', (Request req) async {
    final body = await _readJson(req);
    if (body == null) return _bad('invalid_json');
    final p = _BlogInput.parse(body);
    if (p == null) return _bad('missing_fields');

    return db.pool.runTx<Response>((tx) async {
      final inserted = await tx.execute(
        Sql.named('''
          INSERT INTO blog_posts
            (slug, title, date, description, body_markdown, cover_image_path, published, sort_index)
          VALUES (@slug, @title, @date, @desc, @body, @cover, @published, @sort)
          RETURNING id
        '''),
        parameters: p.params(),
      );
      final id = inserted.first[0] as int;
      await _replaceTags(tx, id, p.tags);
      return Response.ok(jsonEncode({'id': id, 'slug': p.slug}), headers: _json);
    });
  });

  r.put('/<slug>', (Request req, String slug) async {
    final body = await _readJson(req);
    if (body == null) return _bad('invalid_json');
    final p = _BlogInput.parse(body, fallbackSlug: slug);
    if (p == null) return _bad('missing_fields');

    return db.pool.runTx<Response>((tx) async {
      final res = await tx.execute(
        Sql.named('''
          UPDATE blog_posts
             SET slug = @slug, title = @title, date = @date,
                 description = @desc, body_markdown = @body,
                 cover_image_path = @cover, published = @published,
                 sort_index = @sort, updated_at = now()
           WHERE slug = @old_slug
           RETURNING id
        '''),
        parameters: {...p.params(), 'old_slug': slug},
      );
      if (res.isEmpty) {
        return Response.notFound(jsonEncode({'error': 'not_found'}), headers: _json);
      }
      final id = res.first[0] as int;
      await _replaceTags(tx, id, p.tags);
      return Response.ok(jsonEncode({'id': id, 'slug': p.slug}), headers: _json);
    });
  });

  r.delete('/<slug>', (Request req, String slug) async {
    final res = await db.pool.execute(
      Sql.named('DELETE FROM blog_posts WHERE slug = @s RETURNING id'),
      parameters: {'s': slug},
    );
    if (res.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'not_found'}), headers: _json);
    }
    return Response.ok(jsonEncode({'deleted': true}), headers: _json);
  });

  return r;
}

Future<void> _replaceTags(TxSession tx, int postId, List<String> tags) async {
  await tx.execute(
    Sql.named('DELETE FROM blog_post_tags WHERE post_id = @p'),
    parameters: {'p': postId},
  );
  for (final tag in tags) {
    if (tag.trim().isEmpty) continue;
    await tx.execute(
      Sql.named('INSERT INTO blog_post_tags (post_id, tag) VALUES (@p, @t)'),
      parameters: {'p': postId, 't': tag.trim()},
    );
  }
}

class _BlogInput {
  _BlogInput({
    required this.slug,
    required this.title,
    required this.date,
    required this.description,
    required this.body,
    required this.cover,
    required this.published,
    required this.sortIndex,
    required this.tags,
  });

  final String slug;
  final String title;
  final DateTime date;
  final String description;
  final String body;
  final String? cover;
  final bool published;
  final int sortIndex;
  final List<String> tags;

  static _BlogInput? parse(Map<String, dynamic> j, {String? fallbackSlug}) {
    final slug = (j['slug'] as String?)?.trim() ?? fallbackSlug ?? '';
    final title = (j['title'] as String?)?.trim() ?? '';
    final dateStr = (j['date'] as String?)?.trim() ?? '';
    if (slug.isEmpty || title.isEmpty || dateStr.isEmpty) return null;
    final date = DateTime.tryParse(dateStr);
    if (date == null) return null;
    return _BlogInput(
      slug: slug,
      title: title,
      date: date,
      description: (j['description'] as String?) ?? '',
      body: (j['body_markdown'] as String?) ?? '',
      cover: (j['cover'] as String?)?.isEmpty ?? true
          ? null
          : j['cover'] as String,
      published: (j['published'] as bool?) ?? false,
      sortIndex: (j['sort_index'] as int?) ?? 0,
      tags: ((j['tags'] as List?) ?? const []).cast<String>(),
    );
  }

  Map<String, dynamic> params() => {
        'slug': slug,
        'title': title,
        'date': date,
        'desc': description,
        'body': body,
        'cover': cover,
        'published': published,
        'sort': sortIndex,
      };
}

Map<String, dynamic> _row(ResultRow row) {
  final m = row.toColumnMap();
  return {
    'id': m['id'],
    'slug': m['slug'],
    'title': m['title'],
    'date': (m['date'] as DateTime).toIso8601String().substring(0, 10),
    'description': m['description'],
    'cover': m['cover_image_path'],
    'published': m['published'],
    'sort_index': m['sort_index'],
    'body_markdown': m['body_markdown'],
    'tags': (m['tags'] as List).cast<String>(),
  };
}

Future<Map<String, dynamic>?> _readJson(Request req) async {
  try {
    return jsonDecode(await req.readAsString()) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

Response _bad(String code) => Response.badRequest(
    body: jsonEncode({'error': code}), headers: _json);

const _json = {'content-type': 'application/json; charset=utf-8'};
