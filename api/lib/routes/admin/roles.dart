import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../db/pool.dart';

Router adminRolesRoutes(Db db) {
  final r = Router();

  r.get('/', (Request req) async {
    final rows = await db.pool.execute(Sql.named('''
      SELECT id, company, title, start_year, end_year, alt, sort_index
        FROM roles ORDER BY sort_index, start_year
    '''));
    return Response.ok(jsonEncode(rows.map(_row).toList()), headers: _json);
  });

  r.post('/', (Request req) async {
    final body = await _readJson(req);
    if (body == null) return _bad('invalid_json');
    final res = await db.pool.execute(
      Sql.named('''
        INSERT INTO roles (company, title, start_year, end_year, alt, sort_index)
        VALUES (@c, @t, @s, @e, @a, @sort)
        RETURNING id
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
        UPDATE roles
           SET company = @c, title = @t, start_year = @s, end_year = @e,
               alt = @a, sort_index = @sort, updated_at = now()
         WHERE id = @id RETURNING id
      '''),
      parameters: {..._params(body), 'id': int.parse(id)},
    );
    if (res.isEmpty) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: _json);
    return Response.ok(jsonEncode({'id': res.first[0]}), headers: _json);
  });

  r.delete('/<id|[0-9]+>', (Request req, String id) async {
    final res = await db.pool.execute(
      Sql.named('DELETE FROM roles WHERE id = @id RETURNING id'),
      parameters: {'id': int.parse(id)},
    );
    if (res.isEmpty) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: _json);
    return Response.ok(jsonEncode({'deleted': true}), headers: _json);
  });

  return r;
}

Map<String, dynamic> _params(Map<String, dynamic> j) => {
      'c': (j['company'] as String?) ?? '',
      't': (j['title'] as String?) ?? '',
      's': (j['start'] as num?)?.toDouble() ?? 0.0,
      'e': (j['end'] as num?)?.toDouble() ?? 0.0,
      'a': (j['alt'] as bool?) ?? false,
      'sort': (j['sort_index'] as int?) ?? 0,
    };

Map<String, dynamic> _row(ResultRow row) {
  final m = row.toColumnMap();
  return {
    'id': m['id'],
    'company': m['company'],
    'title': m['title'],
    'start': (m['start_year'] as num).toDouble(),
    'end': (m['end_year'] as num).toDouble(),
    'alt': m['alt'],
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
