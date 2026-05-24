import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'models.dart';

class ApiClient {
  ApiClient({required this.baseUrl, String? token})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    if (token != null) _dio.options.headers['Authorization'] = 'Bearer $token';
    _dio.options.validateStatus = (code) => code != null && code < 500;
  }

  final String baseUrl;
  final Dio _dio;

  void setToken(String? token) {
    if (token == null) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<String> login(String email, String password) async {
    final r = await _dio.post('/api/admin/login',
        data: {'email': email, 'password': password});
    if (r.statusCode == 200) return r.data['token'] as String;
    throw ApiException(r.statusCode ?? 0, _err(r.data));
  }

  Future<void> changePassword(String current, String next) async {
    final r = await _dio.post('/api/admin/password',
        data: {'current_password': current, 'new_password': next});
    if (r.statusCode != 200) throw ApiException(r.statusCode ?? 0, _err(r.data));
  }

  // ---- Blog ----
  Future<List<BlogPost>> listBlog() => _getList('/api/admin/blog', BlogPost.fromJson);
  Future<BlogPost> getBlog(String slug) async {
    final r = await _dio.get('/api/admin/blog/$slug');
    _ok(r);
    return BlogPost.fromJson(r.data as Map<String, dynamic>);
  }
  Future<int> createBlog(BlogPost p) async {
    final r = await _dio.post('/api/admin/blog', data: p.toJson());
    _ok(r);
    return r.data['id'] as int;
  }
  Future<void> updateBlog(String slug, BlogPost p) async {
    final r = await _dio.put('/api/admin/blog/$slug', data: p.toJson());
    _ok(r);
  }
  Future<void> deleteBlog(String slug) async {
    final r = await _dio.delete('/api/admin/blog/$slug');
    _ok(r);
  }

  // ---- Roles ----
  Future<List<Role>> listRoles() => _getList('/api/admin/roles', Role.fromJson);
  Future<int> createRole(Role r) async => _postReturnId('/api/admin/roles', r.toJson());
  Future<void> updateRole(int id, Role r) async =>
      _putVoid('/api/admin/roles/$id', r.toJson());
  Future<void> deleteRole(int id) async => _deleteVoid('/api/admin/roles/$id');

  // ---- Skills ----
  Future<List<CoreSkill>> listSkills() =>
      _getList('/api/admin/skills', CoreSkill.fromJson);
  Future<int> createSkill(CoreSkill s) async =>
      _postReturnId('/api/admin/skills', s.toJson());
  Future<void> updateSkill(int id, CoreSkill s) async =>
      _putVoid('/api/admin/skills/$id', s.toJson());
  Future<void> deleteSkill(int id) async =>
      _deleteVoid('/api/admin/skills/$id');

  // ---- Experiments ----
  Future<List<ExperimentCard>> listExperiments() =>
      _getList('/api/admin/experiments', ExperimentCard.fromJson);
  Future<int> createExperiment(ExperimentCard e) async =>
      _postReturnId('/api/admin/experiments', e.toJson());
  Future<void> updateExperiment(int id, ExperimentCard e) async =>
      _putVoid('/api/admin/experiments/$id', e.toJson());
  Future<void> deleteExperiment(int id) async =>
      _deleteVoid('/api/admin/experiments/$id');

  // ---- Lists ----
  Future<List<String>> getList(String key) async {
    final r = await _dio.get('/api/admin/lists/$key');
    _ok(r);
    return ((r.data['values'] as List?) ?? const []).cast<String>();
  }
  Future<void> putList(String key, List<String> values) async {
    final r = await _dio.put('/api/admin/lists/$key', data: {'values': values});
    _ok(r);
  }

  // ---- Messages ----
  Future<List<ContactMessage>> listMessages() =>
      _getList('/api/admin/messages', ContactMessage.fromJson);

  // ---- Media ----
  Future<String> uploadMedia({
    required Uint8List bytes,
    required String filename,
    String? slug,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      if (slug != null) 'slug': slug,
    });
    final r = await _dio.post('/api/admin/media', data: form);
    _ok(r);
    return r.data['url'] as String;
  }

  // ---- helpers ----
  Future<List<T>> _getList<T>(String path, T Function(Map<String, dynamic>) f) async {
    final r = await _dio.get(path);
    _ok(r);
    return (r.data as List).map((j) => f(j as Map<String, dynamic>)).toList();
  }

  Future<int> _postReturnId(String path, Map<String, dynamic> body) async {
    final r = await _dio.post(path, data: body);
    _ok(r);
    return r.data['id'] as int;
  }

  Future<void> _putVoid(String path, Map<String, dynamic> body) async {
    final r = await _dio.put(path, data: body);
    _ok(r);
  }

  Future<void> _deleteVoid(String path) async {
    final r = await _dio.delete(path);
    _ok(r);
  }

  void _ok(Response r) {
    if (r.statusCode == null || r.statusCode! >= 300) {
      throw ApiException(r.statusCode ?? 0, _err(r.data));
    }
  }

  String _err(dynamic data) {
    if (data is Map && data['error'] != null) return data['error'].toString();
    return 'request failed';
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.code);
  final int statusCode;
  final String code;
  bool get isUnauthorized => statusCode == 401;
  @override
  String toString() => 'ApiException($statusCode, $code)';
}
