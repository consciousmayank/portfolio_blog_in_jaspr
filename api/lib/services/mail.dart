import 'dart:io';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class ContactMail {
  ContactMail({
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
  });

  final String name;
  final String email;
  final String subject;
  final String message;
}

class MailService {
  MailService({
    required this.user,
    required this.appPassword,
    required this.adminEmail,
  });

  factory MailService.fromEnv() {
    final user = Platform.environment['GMAIL_USER'];
    final password = Platform.environment['GMAIL_APP_PASSWORD'];
    final admin = Platform.environment['ADMIN_EMAIL'];
    if (user == null || password == null || admin == null) {
      throw StateError(
        'GMAIL_USER, GMAIL_APP_PASSWORD, ADMIN_EMAIL are all required',
      );
    }
    return MailService(user: user, appPassword: password, adminEmail: admin);
  }

  final String user;
  final String appPassword;
  final String adminEmail;

  /// Returns the SMTP message id on success, or null on failure (logged).
  Future<String?> sendContact(ContactMail m) async {
    final smtp = gmail(user, appPassword);
    final msg = Message()
      ..from = Address(user, 'Portfolio Contact')
      ..recipients.add(adminEmail)
      ..subject = '[mayankjoshi.in] ${m.subject}'
      ..text = 'From: ${m.name} <${m.email}>\n\n${m.message}'
      ..headers['Reply-To'] = '${m.name} <${m.email}>';
    try {
      final report = await send(msg, smtp);
      return report.toString();
    } catch (e, st) {
      stderr.writeln('mail: send failed — $e\n$st');
      return null;
    }
  }
}
