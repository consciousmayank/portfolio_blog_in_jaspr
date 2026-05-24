// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:blog_website/components/contact_form.dart' as _contact_form;
import 'package:blog_website/components/hero_typewriter.dart'
    as _hero_typewriter;
import 'package:blog_website/components/theme_toggle.dart' as _theme_toggle;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _contact_form.ContactForm: ClientTarget<_contact_form.ContactForm>(
      'contact_form',
    ),
    _hero_typewriter.HeroTypewriter:
        ClientTarget<_hero_typewriter.HeroTypewriter>('hero_typewriter'),
    _theme_toggle.ThemeToggle: ClientTarget<_theme_toggle.ThemeToggle>(
      'theme_toggle',
    ),
  },
  styles: () => [],
);
