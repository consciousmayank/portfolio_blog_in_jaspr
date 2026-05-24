import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/pool.dart';

Router blogRoutes(Db db) {
  final r = Router();

  r.get('/', (Request req) async {
    final rows = await db.pool.execute(Sql.named('''
      SELECT p.id, p.slug, p.title, p.date, p.description, p.cover_image_path,
             COALESCE(array_agg(t.tag) FILTER (WHERE t.tag IS NOT NULL), '{}') AS tags
        FROM blog_posts p
        LEFT JOIN blog_post_tags t ON t.post_id = p.id
       WHERE p.published = TRUE
       GROUP BY p.id
       ORDER BY p.date DESC, p.id DESC
    '''));
    final out = rows.map(_listRow).toList();
    return Response.ok(jsonEncode(out), headers: _json);
  });

  r.get('/<slug>', (Request req, String slug) async {
    final rows = await db.pool.execute(
      Sql.named('''
        SELECT p.id, p.slug, p.title, p.date, p.description, p.cover_image_path,
               p.body_markdown,
               COALESCE(array_agg(t.tag) FILTER (WHERE t.tag IS NOT NULL), '{}') AS tags
          FROM blog_posts p
          LEFT JOIN blog_post_tags t ON t.post_id = p.id
         WHERE p.slug = @slug AND p.published = TRUE
         GROUP BY p.id
      '''),
      parameters: {'slug': slug},
    );
    if (rows.isEmpty) return Response.notFound('{"error":"not_found"}', headers: _json);
    return Response.ok(jsonEncode(_fullRow(rows.first)), headers: _json);
  });

  return r;
}

Map<String, dynamic> _listRow(ResultRow row) {
  final m = row.toColumnMap();
  return {
    'id': m['id'],
    'slug': m['slug'],
    'title': m['title'],
    'date': (m['date'] as DateTime).toIso8601String().substring(0, 10),
    'description': m['description'],
    'cover': m['cover_image_path'],
    'tags': (m['tags'] as List).cast<String>(),
  };
}

Map<String, dynamic> _fullRow(ResultRow row) {
  final base = _listRow(row);
  final m = row.toColumnMap();
  base['body_markdown'] = m['body_markdown'];
  return base;
}

const _json = {'content-type': 'application/json; charset=utf-8'};
