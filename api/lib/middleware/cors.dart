import 'dart:io';

import 'package:shelf/shelf.dart';

Middleware cors() {
  final allowed = (Platform.environment['CORS_ORIGIN'] ?? '')
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet();

  Map<String, String> headersFor(String? origin) {
    final base = <String, String>{
      'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
      'Access-Control-Allow-Headers': 'Authorization,Content-Type',
      'Access-Control-Max-Age': '600',
      'Vary': 'Origin',
    };
    if (origin != null && allowed.contains(origin)) {
      base['Access-Control-Allow-Origin'] = origin;
    }
    return base;
  }

  return (Handler inner) {
    return (Request request) async {
      final origin = request.headers['origin'];
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headersFor(origin));
      }
      final response = await inner(request);
      return response.change(headers: {...response.headers, ...headersFor(origin)});
    };
  };
}
