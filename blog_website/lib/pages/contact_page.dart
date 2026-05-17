import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../styles/theme.dart';

enum _SubmitState { idle, loading, success, error }

class ContactPage extends StatefulComponent {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();

  @css
  static List<StyleRule> get styles => [
    css('.contact-layout').styles(
      display: .flex,
      margin: .only(top: 2.rem),
      flexWrap: .wrap,
    ),
    css('.contact-form-wrapper').styles(
      margin: .only(right: 3.rem, bottom: 2.rem),
      flex: Flex(grow: 1, shrink: 1, basis: 320.px),
    ),
    css('.contact-info').styles(
      flex: Flex(grow: 0, shrink: 1, basis: 280.px),
    ),
    css('.form-group').styles(margin: .only(bottom: 1.25.rem)),
    css('.form-group label').styles(
      display: .block,
      margin: .only(bottom: 0.4.rem),
      fontSize: 0.9.rem,
      fontWeight: .w500,
    ),
    css('.form-input').styles(
      display: .block,
      width: 100.percent,
      padding: .symmetric(horizontal: 0.75.rem, vertical: 0.6.rem),
      boxSizing: .borderBox,
      border: .symmetric(
        vertical: .solid(color: colorBorder, width: 1.px),
        horizontal: .solid(color: colorBorder, width: 1.px),
      ),
      radius: .all(.circular(6.px)),
      color: colorText,
      fontSize: 0.95.rem,
      backgroundColor: colorSurface,
    ),
    css('.form-input:focus').styles(
      border: .symmetric(
        vertical: .solid(color: colorPrimary, width: 1.px),
        horizontal: .solid(color: colorPrimary, width: 1.px),
      ),
    ),
    css('.form-textarea').styles(overflow: .auto),
    css('.form-banner').styles(
      padding: .all(0.75.rem),
      margin: .only(bottom: 1.rem),
      radius: .all(.circular(6.px)),
      fontSize: 0.9.rem,
      fontWeight: .w500,
    ),
    css('.banner-success').styles(
      color: const Color('#6ee7a0'),
      backgroundColor: const Color('#1a4731'),
    ),
    css('.banner-error').styles(
      color: const Color('#fca5a5'),
      backgroundColor: const Color('#4a1a1a'),
    ),
    css('.contact-detail').styles(
      display: .flex,
      margin: .only(bottom: 1.rem),
      flexDirection: .column,
    ),
    css('.contact-label').styles(
      margin: .only(bottom: 0.2.rem),
      color: colorMuted,
      fontSize: 0.8.rem,
      fontWeight: .w600,
    ),
  ];
}

class _ContactPageState extends State<ContactPage> {
  String _name = '';
  String _email = '';
  String _subject = '';
  String _message = '';
  _SubmitState _state = _SubmitState.idle;
  String _statusMessage = '';

  Future<void> _submit() async {
    if (_name.isEmpty || _email.isEmpty || _subject.isEmpty || _message.isEmpty) {
      setState(() {
        _state = _SubmitState.error;
        _statusMessage = 'Please fill in all fields.';
      });
      return;
    }

    setState(() => _state = _SubmitState.loading);

    try {
      final response = await http.post(
        Uri.parse('/mailer/contact.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'name': _name,
          'email': _email,
          'subject': _subject,
          'message': _message,
          'hp': '',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        _state = data['success'] == true ? _SubmitState.success : _SubmitState.error;
        _statusMessage = data['message']?.toString() ?? 'Something went wrong.';
      });
    } catch (_) {
      setState(() {
        _state = _SubmitState.error;
        _statusMessage =
            'Could not reach the server. Please email consciousmayank@gmail.com directly.';
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'container', [
      section(classes: 'section', [
        h1(classes: 'page-title', [.text('Contact')]),
        div(classes: 'contact-layout', [
          // ── Form ─────────────────────────────────────────────────
          div(classes: 'contact-form-wrapper', [
            if (_state == _SubmitState.success)
              div(classes: 'form-banner banner-success', [.text(_statusMessage)])
            else if (_state == _SubmitState.error)
              div(classes: 'form-banner banner-error', [.text(_statusMessage)]),

            // Honeypot — CSS-hidden field, not display:none (bots fill it, humans don't see it)
            div(
              styles: Styles(raw: {'position': 'absolute', 'left': '-9999px', 'opacity': '0'}),
              [
                input<String>(
                  name: 'hp',
                  type: InputType.text,
                  value: '',
                ),
              ],
            ),

            div(classes: 'form-group', [
              label([.text('Name')], htmlFor: 'contact-name'),
              input<String>(
                id: 'contact-name',
                name: 'name',
                type: InputType.text,
                value: _name,
                onInput: (val) => setState(() => _name = val),
                classes: 'form-input',
              ),
            ]),
            div(classes: 'form-group', [
              label([.text('Email')], htmlFor: 'contact-email'),
              input<String>(
                id: 'contact-email',
                name: 'email',
                type: InputType.email,
                value: _email,
                onInput: (val) => setState(() => _email = val),
                classes: 'form-input',
              ),
            ]),
            div(classes: 'form-group', [
              label([.text('Subject')], htmlFor: 'contact-subject'),
              input<String>(
                id: 'contact-subject',
                name: 'subject',
                type: InputType.text,
                value: _subject,
                onInput: (val) => setState(() => _subject = val),
                classes: 'form-input',
              ),
            ]),
            div(classes: 'form-group', [
              label([.text('Message')], htmlFor: 'contact-message'),
              textarea(
                [.text(_message)],
                id: 'contact-message',
                name: 'message',
                onInput: (val) => setState(() => _message = val),
                classes: 'form-input form-textarea',
                rows: 6,
              ),
            ]),
            button(
              classes: 'btn btn-primary',
              onClick: _state == _SubmitState.loading ? null : () async { await _submit(); },
              [
                .text(_state == _SubmitState.loading ? 'Sending…' : 'Send Message'),
              ],
            ),
          ]),

          // ── Direct Contact ────────────────────────────────────────
          div(classes: 'contact-info', [
            h2(classes: 'section-title', [.text('Get in Touch')]),
            p(classes: 'text-muted', [
              .text(
                "I'm always happy to discuss new opportunities, architecture questions, "
                'or interesting projects.',
              ),
            ]),
            div(classes: 'contact-detail', [
              span(classes: 'contact-label', [.text('Email')]),
              a(href: 'mailto:consciousmayank@gmail.com', [
                .text('consciousmayank@gmail.com'),
              ]),
            ]),
            div(classes: 'contact-detail', [
              span(classes: 'contact-label', [.text('LinkedIn')]),
              a(href: 'https://linkedin.com/in/mayank-joshi-2797b773', [
                .text('mayank-joshi-2797b773'),
              ]),
            ]),
            div(classes: 'contact-detail', [
              span(classes: 'contact-label', [.text('GitHub')]),
              a(href: 'https://github.com/mayankjoshi', [.text('mayankjoshi')]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

}
