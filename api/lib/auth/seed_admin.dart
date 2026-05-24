import 'dart:io';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:postgres/postgres.dart';

import '../db/pool.dart';

/// Idempotently inserts the seed admin from `SEED_ADMIN_EMAIL` /
/// `SEED_ADMIN_PASSWORD` env vars. Does NOT overwrite an existing row —
/// once the operator has logged in and rotated their password via
/// `/api/admin/password`, re-seeding is a no-op.
Future<void> seedAdminIfNeeded(Db db) async {
  final email = Platform.environment['SEED_ADMIN_EMAIL'];
  final password = Platform.environment['SEED_ADMIN_PASSWORD'];
  if (email == null || password == null || email.isEmpty || password.isEmpty) {
    return;
  }
  final existing = await db.pool.execute(
    Sql.named('SELECT 1 FROM admin_users WHERE email = @e LIMIT 1'),
    parameters: {'e': email},
  );
  if (existing.isNotEmpty) return;

  final hash = DBCrypt().hashpw(password, DBCrypt().gensaltWithRounds(12));
  await db.pool.execute(
    Sql.named(
      'INSERT INTO admin_users (email, password_hash) VALUES (@e, @h)',
    ),
    parameters: {'e': email, 'h': hash},
  );
  stderr.writeln('seed_admin: created admin user $email');
}
