import 'dart:io';

import 'package:postgres/postgres.dart';

class Db {
  Db._(this._pool);

  final Pool _pool;

  Pool get pool => _pool;

  static Future<Db> connect() async {
    final url = Platform.environment['DATABASE_URL'];
    if (url == null || url.isEmpty) {
      throw StateError('DATABASE_URL is required');
    }
    final uri = Uri.parse(url);
    final endpoint = Endpoint(
      host: uri.host,
      port: uri.hasPort ? uri.port : 5432,
      database: uri.pathSegments.isNotEmpty ? uri.pathSegments.first : 'portfolio',
      username: Uri.decodeComponent(uri.userInfo.split(':').first),
      password: uri.userInfo.contains(':')
          ? Uri.decodeComponent(uri.userInfo.split(':').sublist(1).join(':'))
          : null,
    );
    final pool = Pool.withEndpoints(
      [endpoint],
      settings: PoolSettings(
        maxConnectionCount: 8,
        sslMode: SslMode.disable,
      ),
    );
    // Eagerly verify connectivity so boot fails loud if DB isn't reachable.
    await pool.execute('SELECT 1');
    return Db._(pool);
  }

  Future<void> close() => _pool.close();
}
