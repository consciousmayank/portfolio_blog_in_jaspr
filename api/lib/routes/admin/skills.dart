import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../db/pool.dart';

Router adminSkillsRoutes(Db db) {
  final r = Router();

  r.get('/', (Request req) async {
    final rows = await db.pool.execute(Sql.named('''
      SELECT id, name, years, percent, hot, sort_index
        FROM core_skills ORDER BY sort_index, id
    '''));
    return Response.ok(jsonEncode(rows.map(_row).toList()), headers: _json);
  });

  r.post('/', (Request req) async {
    final body = await _readJson(req);
    if (body == null) return _bad('invalid_json');
    final res = await db.pool.execute(
      Sql.named('''
        INSERT INTO core_skills (name, years, percent, hot, sort_index)
        VALUES (@n, @y, @p, @h, @sort) RETURNING id
      '''),
      parameters: _params(body),
    );
    return Response.ok(jsonEncode({'id': res.first[0]}), headers: _json);
  });

  r.put('/<id|[0-9]+>', (Request req, String id) async {
    final body = await _readJson(req);
    if (body == null) return _bad('invalid_json');
    final res = await db.pool.execute(
      Sql.named('''
        UPDATE core_skills
           SET name = @n, years = @y, percent = @p, hot = @h,
               sort_index = @sort, updated_at = now()
         WHERE id = @id RETURNING id
      '''),
      parameters: {..._params(body), 'id': int.parse(id)},
    );
    if (res.isEmpty) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: _json);
    return Response.ok(jsonEncode({'id': res.first[0]}), headers: _json);
  });

  r.delete('/<id|[0-9]+>', (Request req, String id) async {
    final res = await db.pool.execute(
      Sql.named('DELETE FROM core_skills WHERE id = @id RETURNING id'),
      parameters: {'id': int.parse(id)},
    );
    if (res.isEmpty) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: _json);
    return Response.ok(jsonEncode({'deleted': true}), headers: _json);
  });

  return r;
}

Map<String, dynamic> _params(Map<String, dynamic> j) => {
      'n': (j['name'] as String?) ?? '',
      'y': (j['years'] as int?) ?? 0,
      'p': (j['percent'] as int?) ?? 0,
      'h': (j['hot'] as bool?) ?? false,
      'sort': (j['sort_index'] as int?) ?? 0,
    };

Map<String, dynamic> _row(ResultRow row) {
  final m = row.toColumnMap();
  return {
    'id': m['id'],
    'name': m['name'],
    'years': m['years'],
    'percent': m['percent'],
    'hot': m['hot'],
    'sort_index': m['sort_index'],
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
