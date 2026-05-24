import 'package:shelf/shelf.dart';

import '../auth/jwt.dart';

const _userKey = 'auth.user';

Middleware requireAuth(JwtService jwt) {
  return (Handler inner) {
    return (Request request) async {
      final header = request.headers['authorization'];
      if (header == null || !header.toLowerCase().startsWith('bearer ')) {
        return Response.unauthorized('missing bearer token');
      }
      final token = header.substring(7).trim();
      final claims = jwt.verify(token);
      if (claims == null) {
        return Response.unauthorized('invalid or expired token');
      }
      return inner(request.change(context: {_userKey: claims}));
    };
  };
}

({int userId, String email}) authedUser(Request request) {
  final claims = request.context[_userKey];
  if (claims is ({int userId, String email})) return claims;
  throw StateError('authedUser called on unauthenticated request');
}
