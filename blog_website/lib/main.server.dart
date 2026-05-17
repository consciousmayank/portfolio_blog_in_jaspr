library;

import 'package:jaspr/server.dart';

import 'app.dart';
import 'main.server.options.dart';
import 'styles/theme.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(Document(
    title: 'Mayank Joshi — Portfolio',
    styles: [
      ...designSystemStyles,
    ],
    body: App(),
  ));
}
