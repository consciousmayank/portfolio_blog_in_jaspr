import 'package:jaspr/jaspr.dart';

import '../data/api_client.dart';
import '../sections/contact_section.dart';
import '../sections/hero_section.dart';
import '../sections/skills_section.dart';
import '../sections/timeline_section.dart';
import '../sections/writing_section.dart';

const _personJsonLd = '{'
    '"@context":"https://schema.org",'
    '"@type":"Person",'
    '"name":"Mayank Joshi",'
    '"url":"https://mayankjoshi.in",'
    '"jobTitle":"Senior Flutter Developer",'
    '"worksFor":{"@type":"Organization","name":"SpiceMoney"},'
    '"description":"Senior Flutter Developer with 12 years of experience. Mobile architect at SpiceMoney.",'
    '"sameAs":["https://github.com/consciousmayank","https://linkedin.com/in/mayankjoshi"],'
    '"knowsAbout":["Flutter","Dart","Mobile Development","Android","iOS","Web Development"]'
    '}';

class HomePage extends StatefulComponent {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        PreloadStateMixin<HomePage>,
        SyncStateMixin<HomePage, Map<String, dynamic>> {
  SiteBundle? _bundle;
  List<BlogPost>? _posts;

  @override
  Future<void> preloadState() async {
    final api = ApiClient();
    _bundle = await api.getSiteBundle();
    _posts = await api.listBlogPosts();
  }

  @override
  Map<String, dynamic> getState() => {
        'bundle': _bundle!.toJson(),
        'posts': _posts!.map((p) => p.toJson()).toList(),
      };

  @override
  void updateState(Map<String, dynamic> value) {
    _bundle = SiteBundle.fromJson(value['bundle'] as Map<String, dynamic>);
    _posts = (value['posts'] as List)
        .map((j) => BlogPost.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Component build(BuildContext context) {
    final bundle = _bundle;
    final posts = _posts;
    if (bundle == null || posts == null) {
      return Component.fragment([]);
    }
    return Component.fragment([
      Document.head(
        children: [
          Component.element(tag: 'link', attributes: {'rel': 'canonical', 'href': 'https://mayankjoshi.in/'}),
          Component.element(tag: 'meta', attributes: {'property': 'og:type', 'content': 'profile'}),
          Component.element(tag: 'meta', attributes: {'property': 'og:url', 'content': 'https://mayankjoshi.in/'}),
          Component.element(tag: 'meta', attributes: {
            'property': 'og:title',
            'content': 'Mayank Joshi — Senior Flutter Developer · Mobile Architect',
          }),
          Component.element(tag: 'meta', attributes: {
            'property': 'og:description',
            'content': 'Senior Flutter Developer with 12 years of experience. '
                'Mobile architect at SpiceMoney. Writing about Flutter, Dart, AI, and '
                'cross-platform development.',
          }),
          Component.element(
            tag: 'script',
            attributes: {'type': 'application/ld+json'},
            children: [Component.text(_personJsonLd)],
          ),
        ],
      ),
      const HeroSection(),
      TimelineSection(roles: bundle.roles),
      SkillsSection(coreSkills: bundle.coreSkills, lists: bundle.lists),
      WritingSection(posts: posts),
      const ContactSection(),
    ]);
  }
}
