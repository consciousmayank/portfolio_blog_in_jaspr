import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf_router/shelf_router.dart';

const _allowedExt = {'png', 'jpg', 'jpeg', 'webp', 'gif', 'svg'};
const _maxBytes = 8 * 1024 * 1024;

Router adminMediaRoutes({required Directory uploadsRoot}) {
  final r = Router();

  r.post('/', (Request req) async {
    final multi = req.multipart();
    if (multi == null) {
      return Response.badRequest(
          body: jsonEncode({'error': 'not_multipart'}), headers: _json);
    }

    String? slugHint;
    List<int>? fileBytes;
    String? originalName;

    await for (final part in multi.parts) {
      final disposition = part.headers['content-disposition'] ?? '';
      final nameMatch = RegExp(r'name="([^"]+)"').firstMatch(disposition);
      final filenameMatch = RegExp(r'filename="([^"]+)"').firstMatch(disposition);
      final fieldName = nameMatch?.group(1);
      if (fieldName == 'slug') {
        slugHint = await part.readString();
      } else if (fieldName == 'file' && filenameMatch != null) {
        originalName = filenameMatch.group(1);
        final builder = BytesBuilder(copy: false);
        await for (final chunk in part) {
          builder.add(chunk);
          if (builder.length > _maxBytes) {
            return Response(413,
                body: jsonEncode({'error': 'too_large'}), headers: _json);
          }
        }
        fileBytes = builder.takeBytes();
      } else {
        await part.readBytes();
      }
    }

    if (fileBytes == null || originalName == null) {
      return Response.badRequest(
          body: jsonEncode({'error': 'missing_file'}), headers: _json);
    }

    final ext = _extOf(originalName).toLowerCase();
    if (!_allowedExt.contains(ext)) {
      return Response.badRequest(
          body: jsonEncode({'error': 'unsupported_type'}), headers: _json);
    }

    final slug = _slugify(slugHint ?? _stem(originalName));
    final now = DateTime.now().toUtc();
    final dir = Directory(
        '${uploadsRoot.path}/${now.year}/${now.month.toString().padLeft(2, '0')}');
    await dir.create(recursive: true);
    final filename = '$slug-${now.millisecondsSinceEpoch}.$ext';
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(fileBytes);

    final relativePath =
        '/uploads/${now.year}/${now.month.toString().padLeft(2, '0')}/$filename';
    return Response.ok(
      jsonEncode({
        'path': relativePath,
        'url': relativePath,
        'mime': lookupMimeType(file.path) ?? 'application/octet-stream',
        'size': fileBytes.length,
      }),
      headers: _json,
    );
  });

  return r;
}

String _extOf(String name) {
  final i = name.lastIndexOf('.');
  return i < 0 ? '' : name.substring(i + 1);
}

String _stem(String name) {
  final i = name.lastIndexOf('.');
  return i < 0 ? name : name.substring(0, i);
}

String _slugify(String s) {
  final lower = s.toLowerCase().trim();
  final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  final trimmed = cleaned.replaceAll(RegExp(r'^-+|-+$'), '');
  return trimmed.isEmpty ? 'upload' : trimmed;
}

const _json = {'content-type': 'application/json; charset=utf-8'};
