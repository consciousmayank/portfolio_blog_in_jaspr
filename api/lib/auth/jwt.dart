import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  JwtService({String? secret})
      : _secret = SecretKey(
          secret ??
              Platform.environment['JWT_SECRET'] ??
              (throw StateError('JWT_SECRET is required')),
        );

  final SecretKey _secret;
  static const _issuer = 'portfolio-api';

  String issue({required int userId, required String email}) {
    final jwt = JWT(
      {'sub': userId.toString(), 'email': email},
      issuer: _issuer,
    );
    return jwt.sign(_secret, expiresIn: const Duration(hours: 24));
  }

  ({int userId, String email})? verify(String token) {
    try {
      final jwt = JWT.verify(token, _secret, issuer: _issuer);
      final payload = jwt.payload as Map<String, dynamic>;
      final sub = payload['sub'];
      final email = payload['email'];
      if (sub is! String || email is! String) return null;
      final id = int.tryParse(sub);
      if (id == null) return null;
      return (userId: id, email: email);
    } catch (_) {
      return null;
    }
  }
}
