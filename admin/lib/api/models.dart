class BlogPost {
  BlogPost({
    this.id,
    required this.slug,
    required this.title,
    required this.date,
    required this.tags,
    required this.description,
    this.cover,
    this.bodyMarkdown = '',
    this.published = false,
    this.sortIndex = 0,
  });

  int? id;
  String slug;
  String title;
  DateTime date;
  List<String> tags;
  String description;
  String? cover;
  String bodyMarkdown;
  bool published;
  int sortIndex;

  factory BlogPost.fromJson(Map<String, dynamic> j) => BlogPost(
        id: j['id'] as int?,
        slug: j['slug'] as String,
        title: j['title'] as String,
        date: DateTime.parse(j['date'] as String),
        tags: ((j['tags'] as List?) ?? const []).cast<String>(),
        description: (j['description'] as String?) ?? '',
        cover: j['cover'] as String?,
        bodyMarkdown: (j['body_markdown'] as String?) ?? '',
        published: (j['published'] as bool?) ?? false,
        sortIndex: (j['sort_index'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'title': title,
        'date': date.toIso8601String().substring(0, 10),
        'description': description,
        'body_markdown': bodyMarkdown,
        'cover': cover,
        'published': published,
        'sort_index': sortIndex,
        'tags': tags,
      };
}

class Role {
  Role({
    this.id,
    required this.company,
    required this.title,
    required this.start,
    required this.end,
    this.alt = false,
    this.sortIndex = 0,
  });

  int? id;
  String company;
  String title;
  double start;
  double end;
  bool alt;
  int sortIndex;

  factory Role.fromJson(Map<String, dynamic> j) => Role(
        id: j['id'] as int?,
        company: j['company'] as String,
        title: j['title'] as String,
        start: (j['start'] as num).toDouble(),
        end: (j['end'] as num).toDouble(),
        alt: (j['alt'] as bool?) ?? false,
        sortIndex: (j['sort_index'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'company': company,
        'title': title,
        'start': start,
        'end': end,
        'alt': alt,
        'sort_index': sortIndex,
      };
}

class CoreSkill {
  CoreSkill({
    this.id,
    required this.name,
    required this.years,
    required this.percent,
    this.hot = false,
    this.sortIndex = 0,
  });

  int? id;
  String name;
  int years;
  int percent;
  bool hot;
  int sortIndex;

  factory CoreSkill.fromJson(Map<String, dynamic> j) => CoreSkill(
        id: j['id'] as int?,
        name: j['name'] as String,
        years: j['years'] as int,
        percent: j['percent'] as int,
        hot: (j['hot'] as bool?) ?? false,
        sortIndex: (j['sort_index'] as int?) ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'years': years,
        'percent': percent,
        'hot': hot,
        'sort_index': sortIndex,
      };
}

class ExperimentCard {
  ExperimentCard({
    this.id,
    required this.code,
    required this.status,
    required this.title,
    required this.body,
    required this.meta,
    this.span = 4,
    this.sortIndex = 0,
    required this.demo,
  });

  int? id;
  String code;
  String status;
  String title;
  String body;
  String meta;
  int span;
  int sortIndex;
  List<List<String>> demo;

  factory ExperimentCard.fromJson(Map<String, dynamic> j) => ExperimentCard(
        id: j['id'] as int?,
        code: j['code'] as String,
        status: j['status'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        meta: (j['meta'] as String?) ?? '',
        span: (j['span'] as int?) ?? 4,
        sortIndex: (j['sort_index'] as int?) ?? 0,
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
        'sort_index': sortIndex,
        'demo': demo,
      };
}

class ContactMessage {
  ContactMessage({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.delivered,
    required this.createdAt,
    this.ip,
    this.userAgent,
  });

  final int id;
  final String name;
  final String email;
  final String subject;
  final String message;
  final bool delivered;
  final DateTime createdAt;
  final String? ip;
  final String? userAgent;

  factory ContactMessage.fromJson(Map<String, dynamic> j) => ContactMessage(
        id: j['id'] as int,
        name: j['name'] as String,
        email: j['email'] as String,
        subject: j['subject'] as String,
        message: j['message'] as String,
        delivered: (j['delivered'] as bool?) ?? false,
        ip: j['ip'] as String?,
        userAgent: j['user_agent'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
