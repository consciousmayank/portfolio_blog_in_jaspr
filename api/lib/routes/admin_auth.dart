import 'dart:convert';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../auth/jwt.dart';
import '../db/pool.dart';

Router adminAuthRoutes({required Db db, required JwtService jwt}) {
  final r = Router();

  r.post('/login', (Request req) async {
    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return Response.badRequest(
          body: jsonEncode({'error': 'invalid_json'}), headers: _json);
    }

    final email = (payload['email'] as String?)?.trim() ?? '';
    final password = (payload['password'] as String?) ?? '';
    if (email.isEmpty || password.isEmpty) {
      return Response.badRequest(
          body: jsonEncode({'error': 'missing_fields'}), headers: _json);
    }

    final rows = await db.pool.execute(
      Sql.named('SELECT id, email, password_hash FROM admin_users WHERE email = @e'),
      parameters: {'e': email},
    );
    if (rows.isEmpty) {
      return Response.unauthorized(jsonEncode({'error': 'invalid_credentials'}),
          headers: _json);
    }
    final m = rows.first.toColumnMap();
    final hash = m['password_hash'] as String;
    if (!DBCrypt().checkpw(password, hash)) {
      return Response.unauthorized(jsonEncode({'error': 'invalid_credentials'}),
          headers: _json);
    }
    final token = jwt.issue(userId: m['id'] as int, email: m['email'] as String);
    return Response.ok(jsonEncode({'token': token}), headers: _json);
  });

  return r;
}

const _json = {'content-type': 'application/json; charset=utf-8'};
