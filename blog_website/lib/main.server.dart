library;

import 'package:jaspr/server.dart';

import 'app.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(Document(
    title: 'Mayank Joshi — Senior Flutter Developer · Mobile Architect',
    lang: 'en',
    head: [
      Component.element(tag: 'link', attributes: {
        'rel': 'preconnect',
        'href': 'https://fonts.googleapis.com',
      }),
      Component.element(tag: 'link', attributes: {
        'rel': 'preconnect',
        'href': 'https://fonts.gstatic.com',
        'crossorigin': '',
      }),
      Component.element(tag: 'link', attributes: {
        'rel': 'stylesheet',
        'href':
            'https://fonts.googleapis.com/css2?family=Instrument+Serif:ital@0;1&family=Geist:wght@300;400;500;600;700&family=Geist+Mono:wght@300;400;500;600&display=swap',
      }),
      Component.element(tag: 'link', attributes: {
        'rel': 'stylesheet',
        'href': '/styles.css',
      }),
      Component.element(tag: 'meta', attributes: {
        'name': 'description',
        'content': 'Mayank Joshi — Senior Flutter Developer with 12 years of experience. '
            'Mobile architect at SpiceMoney. Writing about Flutter, Dart, AI, and '
            'cross-platform development.',
      }),
      Component.element(tag: 'meta', attributes: {
        'property': 'og:site_name',
        'content': 'Mayank Joshi',
      }),
      Component.element(tag: 'meta', attributes: {
        'property': 'og:locale',
        'content': 'en_US',
      }),
      Component.element(tag: 'meta', attributes: {
        'property': 'og:image',
        'content': 'https://mayankjoshi.in/images/og-default.png',
      }),
      Component.element(tag: 'meta', attributes: {
        'name': 'twitter:card',
        'content': 'summary_large_image',
      }),
      Component.element(tag: 'meta', attributes: {
        'name': 'twitter:creator',
        'content': '@consciousmayank',
      }),
    ],
    body: const App(),
  ));
}
