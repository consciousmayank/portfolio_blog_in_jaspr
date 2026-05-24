import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class BlogPost {
  const BlogPost({
    required this.slug,
    required this.title,
    required this.date,
    required this.tags,
    required this.description,
    this.cover,
    this.contentMarkdown = '',
  });

  final String slug;
  final String title;
  final String date;
  final List<String> tags;
  final String description;
  final String? cover;
  final String contentMarkdown;

  factory BlogPost.fromJson(Map<String, dynamic> j, {bool withBody = false}) {
    return BlogPost(
      slug: j['slug'] as String,
      title: j['title'] as String,
      date: j['date'] as String,
      tags: (j['tags'] as List).cast<String>(),
      description: (j['description'] as String?) ?? '',
      cover: j['cover'] as String?,
      contentMarkdown:
          withBody ? (j['body_markdown'] as String?) ?? '' : '',
    );
  }

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'title': title,
        'date': date,
        'tags': tags,
        'description': description,
        'cover': cover,
        'body_markdown': contentMarkdown,
      };
}

class Role {
  const Role({
    required this.company,
    required this.title,
    required this.start,
    required this.end,
    this.alt = false,
  });
  final String company;
  final String title;
  final double start;
  final double end;
  final bool alt;

  factory Role.fromJson(Map<String, dynamic> j) => Role(
        company: j['company'] as String,
        title: j['title'] as String,
        start: (j['start'] as num).toDouble(),
        end: (j['end'] as num).toDouble(),
        alt: (j['alt'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'company': company,
        'title': title,
        'start': start,
        'end': end,
        'alt': alt,
      };
}

class CoreSkill {
  const CoreSkill({
    required this.name,
    required this.years,
    required this.percent,
    this.hot = false,
  });
  final String name;
  final int years;
  final int percent;
  final bool hot;

  factory CoreSkill.fromJson(Map<String, dynamic> j) => CoreSkill(
        name: j['name'] as String,
        years: j['years'] as int,
        percent: j['percent'] as int,
        hot: (j['hot'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'years': years,
        'percent': percent,
        'hot': hot,
      };
}

class ExperimentCard {
  const ExperimentCard({
    required this.code,
    required this.status,
    required this.title,
    required this.body,
    required this.demo,
    required this.meta,
    this.span = 4,
  });
  final String code;
  final String status;
  final String title;
  final String body;
  final List<List<String>> demo;
  final String meta;
  final int span;

  factory ExperimentCard.fromJson(Map<String, dynamic> j) => ExperimentCard(
        code: j['code'] as String,
        status: j['status'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        meta: (j['meta'] as String?) ?? '',
        span: (j['span'] as int?) ?? 4,
        demo: ((j['demo'] as List?) ?? const [])
            .map<List<String>>((e) => (e as List).cast<String>())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'status': status,
        'title': title,
        'body': body,
        'meta': meta,
        'span': span,
        'demo': demo,
      };
}

class SiteBundle {
  const SiteBundle({
    required this.roles,
    required this.coreSkills,
    required this.experiments,
    required this.lists,
  });
  final List<Role> roles;
  final List<CoreSkill> coreSkills;
  final List<ExperimentCard> experiments;
  final Map<String, List<String>> lists;

  List<String> list(String key) => lists[key] ?? const <String>[];

  Map<String, dynamic> toJson() => {
        'roles': roles.map((r) => r.toJson()).toList(),
        'coreSkills': coreSkills.map((s) => s.toJson()).toList(),
        'experiments': experiments.map((e) => e.toJson()).toList(),
        'lists': lists,
      };

  factory SiteBundle.fromJson(Map<String, dynamic> j) => SiteBundle(
        roles: (j['roles'] as List)
            .map((e) => Role.fromJson(e as Map<String, dynamic>))
            .toList(),
        coreSkills: (j['coreSkills'] as List)
            .map((e) => CoreSkill.fromJson(e as Map<String, dynamic>))
            .toList(),
        experiments: (j['experiments'] as List)
            .map((e) => ExperimentCard.fromJson(e as Map<String, dynamic>))
            .toList(),
        lists: ((j['lists'] as Map?) ?? const {}).map(
          (k, v) => MapEntry(k as String, (v as List).cast<String>()),
        ),
      );
}

class ApiClient {
  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = (baseUrl ?? _envBaseUrl() ?? 'http://localhost:8080').trimRight(),
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static String? _envBaseUrl() {
    try {
      return Platform.environment['API_BASE_URL'];
    } catch (_) {
      return null; // browser context — never reached for AsyncStatelessComponent
    }
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<BlogPost>> listBlogPosts() async {
    final resp = await _client.get(_uri('/api/blog'));
    _ensureOk(resp);
    final list = jsonDecode(resp.body) as List;
    return list.map((j) => BlogPost.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<BlogPost?> getBlogPost(String slug) async {
    final resp = await _client.get(_uri('/api/blog/$slug'));
    if (resp.statusCode == 404) return null;
    _ensureOk(resp);
    return BlogPost.fromJson(
      jsonDecode(resp.body) as Map<String, dynamic>,
      withBody: true,
    );
  }

  Future<SiteBundle> getSiteBundle() async {
    final resp = await _client.get(_uri('/api/site'));
    _ensureOk(resp);
    final j = jsonDecode(resp.body) as Map<String, dynamic>;
    return SiteBundle(
      roles: (j['roles'] as List)
          .map((e) => Role.fromJson(e as Map<String, dynamic>))
          .toList(),
      coreSkills: (j['coreSkills'] as List)
          .map((e) => CoreSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
      experiments: (j['experiments'] as List)
          .map((e) => ExperimentCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      lists: ((j['lists'] as Map?) ?? const {}).map(
        (k, v) => MapEntry(k as String, (v as List).cast<String>()),
      ),
    );
  }

  void _ensureOk(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) return;
    throw HttpException(
      'API ${r.request?.url} failed: ${r.statusCode} ${r.body}',
    );
  }
}
