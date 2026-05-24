import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/pool.dart';

Router siteRoutes(Db db) {
  final r = Router();

  r.get('/', (Request req) async {
    final roles = await db.pool.execute(Sql.named('''
      SELECT company, title, start_year, end_year, alt
        FROM roles ORDER BY sort_index, start_year
    '''));
    final skills = await db.pool.execute(Sql.named('''
      SELECT name, years, percent, hot
        FROM core_skills ORDER BY sort_index, id
    '''));
    final cards = await db.pool.execute(Sql.named('''
      SELECT id, code, status, title, body, meta, span
        FROM experiment_cards ORDER BY sort_index, id
    '''));
    final demos = await db.pool.execute(Sql.named('''
      SELECT card_id, idx, line, style
        FROM experiment_card_demo ORDER BY card_id, idx
    '''));
    final lists = await db.pool.execute(Sql.named('''
      SELECT list_key, idx, value
        FROM site_lists ORDER BY list_key, idx
    '''));

    final demoByCard = <int, List<List<String>>>{};
    for (final row in demos) {
      final m = row.toColumnMap();
      final cid = m['card_id'] as int;
      demoByCard.putIfAbsent(cid, () => <List<String>>[])
          .add([m['line'] as String, m['style'] as String]);
    }

    final experiments = cards.map((row) {
      final m = row.toColumnMap();
      return {
        'id': m['id'],
        'code': m['code'],
        'status': m['status'],
        'title': m['title'],
        'body': m['body'],
        'meta': m['meta'],
        'span': m['span'],
        'demo': demoByCard[m['id']] ?? const <List<String>>[],
      };
    }).toList();

    final listMap = <String, List<String>>{};
    for (final row in lists) {
      final m = row.toColumnMap();
      listMap.putIfAbsent(m['list_key'] as String, () => <String>[])
          .add(m['value'] as String);
    }

    return Response.ok(
      jsonEncode({
        'roles': roles.map((r) {
          final m = r.toColumnMap();
          return {
            'company': m['company'],
            'title': m['title'],
            'start': (m['start_year'] as num).toDouble(),
            'end': (m['end_year'] as num).toDouble(),
            'alt': m['alt'],
          };
        }).toList(),
        'coreSkills': skills.map((r) {
          final m = r.toColumnMap();
          return {
            'name': m['name'],
            'years': m['years'],
            'percent': m['percent'],
            'hot': m['hot'],
          };
        }).toList(),
        'experiments': experiments,
        'lists': listMap,
      }),
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  });

  return r;
}
