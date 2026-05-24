import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../db/pool.dart';

Router adminExperimentsRoutes(Db db) {
  final r = Router();

  r.get('/', (Request req) async {
    final cards = await db.pool.execute(Sql.named('''
      SELECT id, code, status, title, body, meta, span, sort_index
        FROM experiment_cards ORDER BY sort_index, id
    '''));
    final demos = await db.pool.execute(Sql.named('''
      SELECT card_id, idx, line, style
        FROM experiment_card_demo ORDER BY card_id, idx
    '''));
    final demoByCard = <int, List<List<String>>>{};
    for (final row in demos) {
      final m = row.toColumnMap();
      demoByCard.putIfAbsent(m['card_id'] as int, () => <List<String>>[])
          .add([m['line'] as String, m['style'] as String]);
    }
    final out = cards.map((row) {
      final m = row.toColumnMap();
      return {
        'id': m['id'],
        'code': m['code'],
        'status': m['status'],
        'title': m['title'],
        'body': m['body'],
        'meta': m['meta'],
        'span': m['span'],
        'sort_index': m['sort_index'],
        'demo': demoByCard[m['id']] ?? const <List<String>>[],
      };
    }).toList();
    return Response.ok(jsonEncode(out), headers: _json);
  });

  r.post('/', (Request req) async {
    final body = await _readJson(req);
    if (body == null) return _bad('invalid_json');
    return db.pool.runTx<Response>((tx) async {
      final res = await tx.execute(
        Sql.named('''
          INSERT INTO experiment_cards (code, status, title, body, meta, span, sort_index)
          VALUES (@c, @s, @t, @b, @m, @sp, @sort) RETURNING id
        '''),
        parameters: _params(body),
      );
      final id = res.first[0] as int;
      await _replaceDemo(tx, id, _demoOf(body));
      return Response.ok(jsonEncode({'id': id}), headers: _json);
    });
  });

  r.put('/<id|[0-9]+>', (Request req, String id) async {
    final body = await _readJson(req);
    if (body == null) return _bad('invalid_json');
    final intId = int.parse(id);
    return db.pool.runTx<Response>((tx) async {
      final res = await tx.execute(
        Sql.named('''
          UPDATE experiment_cards
             SET code = @c, status = @s, title = @t, body = @b, meta = @m,
                 span = @sp, sort_index = @sort, updated_at = now()
           WHERE id = @id RETURNING id
        '''),
        parameters: {..._params(body), 'id': intId},
      );
      if (res.isEmpty) {
        return Response.notFound(jsonEncode({'error': 'not_found'}), headers: _json);
      }
      await _replaceDemo(tx, intId, _demoOf(body));
      return Response.ok(jsonEncode({'id': intId}), headers: _json);
    });
  });

  r.delete('/<id|[0-9]+>', (Request req, String id) async {
    final res = await db.pool.execute(
      Sql.named('DELETE FROM experiment_cards WHERE id = @id RETURNING id'),
      parameters: {'id': int.parse(id)},
    );
    if (res.isEmpty) return Response.notFound(jsonEncode({'error': 'not_found'}), headers: _json);
    return Response.ok(jsonEncode({'deleted': true}), headers: _json);
  });

  return r;
}

Future<void> _replaceDemo(TxSession tx, int cardId, List<List<String>> demo) async {
  await tx.execute(
    Sql.named('DELETE FROM experiment_card_demo WHERE card_id = @c'),
    parameters: {'c': cardId},
  );
  for (var i = 0; i < demo.length; i++) {
    final pair = demo[i];
    final line = pair.isNotEmpty ? pair[0] : '';
    final style = pair.length > 1 ? pair[1] : '';
    await tx.execute(
      Sql.named('''
        INSERT INTO experiment_card_demo (card_id, idx, line, style)
        VALUES (@c, @i, @l, @s)
      '''),
      parameters: {'c': cardId, 'i': i, 'l': line, 's': style},
    );
  }
}

List<List<String>> _demoOf(Map<String, dynamic> j) {
  final raw = (j['demo'] as List?) ?? const [];
  return raw.map<List<String>>((e) => (e as List).cast<String>()).toList();
}

Map<String, dynamic> _params(Map<String, dynamic> j) => {
      'c': (j['code'] as String?) ?? '',
      's': (j['status'] as String?) ?? '',
      't': (j['title'] as String?) ?? '',
      'b': (j['body'] as String?) ?? '',
      'm': (j['meta'] as String?) ?? '',
      'sp': (j['span'] as int?) ?? 4,
      'sort': (j['sort_index'] as int?) ?? 0,
    };

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
