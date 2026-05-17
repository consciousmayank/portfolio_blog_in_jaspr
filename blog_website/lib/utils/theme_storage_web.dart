// ignore: deprecated_member_use
import 'dart:html' as html;

String? getSavedTheme() => html.window.localStorage['theme'];
void saveTheme(String theme) => html.window.localStorage['theme'] = theme;
