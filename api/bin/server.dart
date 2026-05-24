import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:portfolio_api/auth/jwt.dart';
import 'package:portfolio_api/auth/seed_admin.dart';
import 'package:portfolio_api/db/migrator.dart';
import 'package:portfolio_api/db/pool.dart';
import 'package:portfolio_api/middleware/auth.dart';
import 'package:portfolio_api/middleware/cors.dart';
import 'package:portfolio_api/routes/admin/blog.dart';
import 'package:portfolio_api/routes/admin/experiments.dart';
import 'package:portfolio_api/routes/admin/lists.dart';
import 'package:portfolio_api/routes/admin/media.dart';
import 'package:portfolio_api/routes/admin/messages.dart';
import 'package:portfolio_api/routes/admin/password.dart';
import 'package:portfolio_api/routes/admin/roles.dart';
import 'package:portfolio_api/routes/admin/skills.dart';
import 'package:portfolio_api/routes/admin_auth.dart';
import 'package:portfolio_api/routes/blog.dart';
import 'package:portfolio_api/routes/contact.dart';
import 'package:portfolio_api/routes/site.dart';
import 'package:portfolio_api/services/mail.dart';
import 'package:portfolio_api/services/rate_limit.dart';

Future<void> main(List<String> args) async {
  final db = await Db.connect();
  await Migrator(db, directory: _migrationsDir()).run();
  await seedAdminIfNeeded(db);

  final jwt = JwtService();
  final mail = MailService.fromEnv();
  final contactLimiter = IpRateLimiter(
    maxRequests: 5,
    window: const Duration(minutes: 10),
  );
  final uploadsRoot = Directory(
      Platform.environment['UPLOADS_DIR'] ?? '/app/uploads');
  await uploadsRoot.create(recursive: true);

  final guarded = const Pipeline().addMiddleware(requireAuth(jwt));

  final adminRouter = Router()
    ..mount('/blog', guarded.addHandler(adminBlogRoutes(db).call))
    ..mount('/roles', guarded.addHandler(adminRolesRoutes(db).call))
    ..mount('/skills', guarded.addHandler(adminSkillsRoutes(db).call))
    ..mount('/experiments', guarded.addHandler(adminExperimentsRoutes(db).call))
    ..mount('/lists', guarded.addHandler(adminListsRoutes(db).call))
    ..mount('/messages', guarded.addHandler(adminMessagesRoutes(db).call))
    ..mount('/password', guarded.addHandler(adminPasswordRoutes(db).call))
    ..mount('/media',
        guarded.addHandler(adminMediaRoutes(uploadsRoot: uploadsRoot).call))
    ..mount('/', adminAuthRoutes(db: db, jwt: jwt).call);

  final root = Router()
    ..get('/health', (Request _) => Response.ok('ok'))
    ..mount('/api/blog', blogRoutes(db).call)
    ..mount('/api/site', siteRoutes(db).call)
    ..mount('/api/contact',
        contactRoutes(db: db, mail: mail, limiter: contactLimiter).call)
    ..mount('/api/admin', adminRouter.call);

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(cors())
      .addHandler(root.call);

  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final server = await shelf_io.serve(pipeline, InternetAddress.anyIPv4, port);
  stderr.writeln('portfolio-api listening on :${server.port}');

  ProcessSignal.sigterm.watch().listen((_) async {
    stderr.writeln('SIGTERM — shutting down');
    await server.close(force: false);
    await db.close();
    exit(0);
  });
}

Directory _migrationsDir() {
  final candidates = [
    Directory('/app/migrations'),
    Directory('migrations'),
    Directory('api/migrations'),
  ];
  for (final d in candidates) {
    if (d.existsSync()) return d;
  }
  throw StateError('migrations directory not found in: $candidates');
}
