import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../db/pool.dart';

const _allowedKeys = {
  'stateManagement',
  'aiStack',
  'architecture',
  'webOps',
  'platforms',
};

Router adminListsRoutes(Db db) {
  final r = Router();

  r.get('/<key>', (Request req, String key) async {
    if (!_allowedKeys.contains(key)) {
      return Response.notFound(jsonEncode({'error': 'unknown_key'}), headers: _json);
    }
    final rows = await db.pool.execute(
      Sql.named('SELECT value FROM site_lists WHERE list_key = @k ORDER BY idx'),
      parameters: {'k': key},
    );
    final values = rows.map((r) => r[0] as String).toList();
    return Response.ok(jsonEncode({'key': key, 'values': values}), headers: _json);
  });

  r.put('/<key>', (Request req, String key) async {
    if (!_allowedKeys.contains(key)) {
      return Response.notFound(jsonEncode({'error': 'unknown_key'}), headers: _json);
    }
    Map<String, dynamic> body;
    try {
      body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return Response.badRequest(
          body: jsonEncode({'error': 'invalid_json'}), headers: _json);
    }
    final values = ((body['values'] as List?) ?? const []).cast<String>();

    await db.pool.runTx((tx) async {
      await tx.execute(
        Sql.named('DELETE FROM site_lists WHERE list_key = @k'),
        parameters: {'k': key},
      );
      for (var i = 0; i < values.length; i++) {
        await tx.execute(
          Sql.named('''
            INSERT INTO site_lists (list_key, idx, value) VALUES (@k, @i, @v)
          '''),
          parameters: {'k': key, 'i': i, 'v': values[i]},
        );
      }
    });
    return Response.ok(
        jsonEncode({'key': key, 'count': values.length}), headers: _json);
  });

  return r;
}

const _json = {'content-type': 'application/json; charset=utf-8'};
