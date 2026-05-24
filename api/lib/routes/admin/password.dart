import 'dart:convert';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../db/pool.dart';
import '../../middleware/auth.dart';

Router adminPasswordRoutes(Db db) {
  final r = Router();

  r.post('/', (Request req) async {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return Response.badRequest(
          body: jsonEncode({'error': 'invalid_json'}), headers: _json);
    }
    final current = (body['current_password'] as String?) ?? '';
    final next = (body['new_password'] as String?) ?? '';
    if (current.isEmpty || next.length < 12) {
      return Response.badRequest(
          body: jsonEncode({'error': 'invalid_input'}), headers: _json);
    }

    final user = authedUser(req);
    final rows = await db.pool.execute(
      Sql.named('SELECT password_hash FROM admin_users WHERE id = @id'),
      parameters: {'id': user.userId},
    );
    if (rows.isEmpty) {
      return Response.unauthorized(jsonEncode({'error': 'no_user'}), headers: _json);
    }
    final hash = rows.first[0] as String;
    if (!DBCrypt().checkpw(current, hash)) {
      return Response.unauthorized(
          jsonEncode({'error': 'invalid_credentials'}), headers: _json);
    }
    final newHash = DBCrypt().hashpw(next, DBCrypt().gensaltWithRounds(12));
    await db.pool.execute(
      Sql.named('''
        UPDATE admin_users SET password_hash = @h, updated_at = now()
         WHERE id = @id
      '''),
      parameters: {'h': newHash, 'id': user.userId},
    );
    return Response.ok(jsonEncode({'ok': true}), headers: _json);
  });

  return r;
}

const _json = {'content-type': 'application/json; charset=utf-8'};
