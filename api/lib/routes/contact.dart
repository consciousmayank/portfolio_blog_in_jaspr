import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../db/pool.dart';
import '../services/mail.dart';
import '../services/rate_limit.dart';

Router contactRoutes({
  required Db db,
  required MailService mail,
  required IpRateLimiter limiter,
}) {
  final r = Router();

  r.post('/', (Request req) async {
    final ip = _clientIp(req);
    if (!limiter.allow(ip)) {
      return Response(429,
          body: jsonEncode({'error': 'rate_limited'}), headers: _json);
    }

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return Response.badRequest(
          body: jsonEncode({'error': 'invalid_json'}), headers: _json);
    }

    // Honeypot — bots fill every field. Real humans never see `hp`.
    if ((payload['hp'] as String?)?.isNotEmpty ?? false) {
      // Pretend success so bots don't tune their attack.
      return Response(202, body: jsonEncode({'ok': true}), headers: _json);
    }

    final name = _str(payload['name']);
    final email = _str(payload['email']);
    final subject = _str(payload['subject']);
    final message = _str(payload['message']);
    if (name.isEmpty || email.isEmpty || subject.isEmpty || message.isEmpty) {
      return Response.badRequest(
          body: jsonEncode({'error': 'missing_fields'}), headers: _json);
    }
    if (!email.contains('@') || email.length > 254) {
      return Response.badRequest(
          body: jsonEncode({'error': 'invalid_email'}), headers: _json);
    }

    final userAgent = req.headers['user-agent'];
    final sent = await mail.sendContact(ContactMail(
      name: name,
      email: email,
      subject: subject,
      message: message,
    ));

    await db.pool.execute(
      Sql.named('''
        INSERT INTO contact_messages
          (name, email, subject, message, ip, user_agent, delivered, smtp_message_id)
        VALUES (@n, @e, @s, @m, @ip, @ua, @d, @mid)
      '''),
      parameters: {
        'n': name,
        'e': email,
        's': subject,
        'm': message,
        'ip': ip,
        'ua': userAgent,
        'd': sent != null,
        'mid': sent,
      },
    );

    return Response(202, body: jsonEncode({'ok': true}), headers: _json);
  });

  return r;
}

String _str(dynamic v) => (v is String) ? v.trim() : '';

String _clientIp(Request req) {
  final xff = req.headers['x-forwarded-for'];
  if (xff != null && xff.isNotEmpty) return xff.split(',').first.trim();
  return req.headers['x-real-ip'] ?? 'unknown';
}

const _json = {'content-type': 'application/json; charset=utf-8'};
