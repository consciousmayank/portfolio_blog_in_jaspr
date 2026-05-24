import 'dart:io';

import 'package:postgres/postgres.dart';

import 'pool.dart';

class Migrator {
  Migrator(this.db, {required this.directory});

  final Db db;
  final Directory directory;

  Future<void> run() async {
    await db.pool.execute('''
      CREATE TABLE IF NOT EXISTS _schema_migrations (
        version    INT PRIMARY KEY,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
      )
    ''');

    final applied = await db.pool.execute(
      'SELECT coalesce(max(version), 0) AS v FROM _schema_migrations',
    );
    final current = applied.first[0] as int;

    final files = directory
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final name = file.uri.pathSegments.last;
      final version = int.tryParse(name.split('_').first);
      if (version == null) {
        stderr.writeln('migrator: skipping $name (no numeric prefix)');
        continue;
      }
      if (version <= current) continue;

      final sql = await file.readAsString();
      stderr.writeln('migrator: applying $name');
      await db.pool.runTx((tx) async {
        await tx.execute(Sql(sql));
        await tx.execute(
          Sql.named('INSERT INTO _schema_migrations (version) VALUES (@v)'),
          parameters: {'v': version},
        );
      });
    }
  }
}
