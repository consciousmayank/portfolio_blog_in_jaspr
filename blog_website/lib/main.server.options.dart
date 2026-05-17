// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:blog_website/components/blog_card.dart' as _blog_card;
import 'package:blog_website/components/experience_card.dart'
    as _experience_card;
import 'package:blog_website/components/footer.dart' as _footer;
import 'package:blog_website/components/nav_bar.dart' as _nav_bar;
import 'package:blog_website/components/skill_chip.dart' as _skill_chip;
import 'package:blog_website/pages/about_page.dart' as _about_page;
import 'package:blog_website/pages/blog_page.dart' as _blog_page;
import 'package:blog_website/pages/blog_post_page.dart' as _blog_post_page;
import 'package:blog_website/pages/contact_page.dart' as _contact_page;
import 'package:blog_website/pages/home_page.dart' as _home_page;
import 'package:blog_website/app.dart' as _app;

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
  clients: {_app.App: ClientTarget<_app.App>('app')},
  styles: () => [
    ..._app.App.styles,
    ..._blog_card.BlogCard.styles,
    ..._experience_card.ExperienceCard.styles,
    ..._footer.Footer.styles,
    ..._nav_bar.NavBar.styles,
    ..._skill_chip.SkillChip.styles,
    ..._about_page.AboutPage.styles,
    ..._blog_page.BlogPage.styles,
    ..._blog_post_page.BlogPostPage.styles,
    ..._contact_page.ContactPage.styles,
    ..._home_page.HomePage.styles,
  ],
);
