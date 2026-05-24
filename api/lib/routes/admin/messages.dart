import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../db/pool.dart';

Router adminMessagesRoutes(Db db) {
  final r = Router();

  r.get('/', (Request req) async {
    final rows = await db.pool.execute(Sql.named('''
      SELECT id, name, email, subject, message, ip, user_agent,
             delivered, smtp_message_id, created_at
        FROM contact_messages
       ORDER BY created_at DESC
       LIMIT 500
    '''));
    final out = rows.map((row) {
      final m = row.toColumnMap();
      return {
        'id': m['id'],
        'name': m['name'],
        'email': m['email'],
        'subject': m['subject'],
        'message': m['message'],
        'ip': m['ip']?.toString(),
        'user_agent': m['user_agent'],
        'delivered': m['delivered'],
        'smtp_message_id': m['smtp_message_id'],
        'created_at': (m['created_at'] as DateTime).toIso8601String(),
      };
    }).toList();
    return Response.ok(jsonEncode(out), headers: _json);
  });

  return r;
}

const _json = {'content-type': 'application/json; charset=utf-8'};
