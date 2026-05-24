import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class ContactForm extends StatefulComponent {
  const ContactForm({super.key});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  String _name = '';
  String _email = '';
  String _subject = '';
  String _message = '';
  String _hp = ''; // honeypot — must stay empty
  bool _submitting = false;
  String? _error;
  bool _ok = false;

  Future<void> _submit() async {
    if (_submitting) return;
    final missing = _name.trim().isEmpty ||
        _email.trim().isEmpty ||
        _subject.trim().isEmpty ||
        _message.trim().isEmpty;
    if (missing) {
      setState(() => _error = 'Please fill in every field.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final resp = await http.post(
        Uri.parse('/api/contact'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'name': _name.trim(),
          'email': _email.trim(),
          'subject': _subject.trim(),
          'message': _message.trim(),
          'hp': _hp,
        }),
      );
      if (resp.statusCode == 202) {
        setState(() {
          _ok = true;
          _submitting = false;
        });
      } else if (resp.statusCode == 429) {
        setState(() {
          _error = 'You\'ve sent a few already — try again in a few minutes.';
          _submitting = false;
        });
      } else {
        setState(() {
          _error = 'Something went wrong. Please email me directly.';
          _submitting = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Network error. Please email me directly.';
        _submitting = false;
      });
    }
  }

  @override
  Component build(BuildContext context) {
    if (_ok) return _success();

    return Component.element(
      tag: 'form',
      classes: 'ct-form',
      events: {
        'submit': (event) {
          (event as dynamic).preventDefault();
          _submit();
        },
      },
      children: [
        _field(
          id: 'name',
          label: 'Your name',
          type: 'text',
          value: _name,
          onInput: (v) => setState(() => _name = v),
          autocomplete: 'name',
        ),
        _field(
          id: 'email',
          label: 'Email',
          type: 'email',
          value: _email,
          onInput: (v) => setState(() => _email = v),
          autocomplete: 'email',
        ),
        _field(
          id: 'subject',
          label: 'Subject',
          type: 'text',
          value: _subject,
          onInput: (v) => setState(() => _subject = v),
        ),
        _textarea(
          id: 'message',
          label: 'Message',
          value: _message,
          onInput: (v) => setState(() => _message = v),
        ),
        // Honeypot — hidden from real users via aria + tab-index + offscreen.
        div(
          styles: Styles(raw: {
            'position': 'absolute',
            'left': '-10000px',
            'width': '1px',
            'height': '1px',
            'overflow': 'hidden',
          }),
          attributes: const {'aria-hidden': 'true'},
          [
            Component.element(
              tag: 'label',
              attributes: const {'for': 'hp'},
              children: [Component.text('Leave this empty')],
            ),
            Component.element(
              tag: 'input',
              attributes: {
                'id': 'hp',
                'name': 'hp',
                'type': 'text',
                'autocomplete': 'off',
                'tabindex': '-1',
                'value': _hp,
              },
              events: {
                'input': (e) =>
                    setState(() => _hp = ((e as dynamic).target.value as String?) ?? ''),
              },
            ),
          ],
        ),
        if (_error != null)
          div(
            classes: 'ct-error',
            styles: Styles(raw: {'color': 'var(--accent)', 'margin-top': '8px'}),
            [.text(_error!)],
          ),
        div(classes: 'ct-actions', styles: Styles(raw: {'margin-top': '12px'}), [
          Component.element(
            tag: 'button',
            classes: 'btn',
            attributes: {
              'type': 'submit',
              if (_submitting) 'disabled': '',
            },
            children: [
              Component.text(_submitting ? 'Sending…' : 'Send message →'),
            ],
          ),
        ]),
      ],
    );
  }

  Component _success() {
    return div(
      classes: 'ct-success',
      styles: Styles(raw: {
        'padding': '20px',
        'border': '1px solid var(--accent)',
        'border-radius': '8px',
        'background': 'var(--accent-soft)',
      }),
      [
        h4(styles: Styles(raw: {'margin': '0 0 8px'}), [.text('Thanks — got it.')]),
        p(styles: Styles(raw: {'margin': '0'}), [
          .text(
            "I read every message I get. Expect a reply within a day or two — "
            "from consciousmayank@gmail.com.",
          ),
        ]),
      ],
    );
  }

  Component _field({
    required String id,
    required String label,
    required String type,
    required String value,
    required void Function(String) onInput,
    String? autocomplete,
  }) {
    return div(classes: 'ct-field', styles: Styles(raw: {'margin-bottom': '10px'}), [
      Component.element(
        tag: 'label',
        attributes: {'for': id},
        children: [Component.text(label)],
      ),
      Component.element(
        tag: 'input',
        attributes: {
          'id': id,
          'name': id,
          'type': type,
          'value': value,
          if (autocomplete != null) 'autocomplete': autocomplete,
          'required': '',
        },
        events: {
          'input': (e) => onInput(((e as dynamic).target.value as String?) ?? ''),
        },
      ),
    ]);
  }

  Component _textarea({
    required String id,
    required String label,
    required String value,
    required void Function(String) onInput,
  }) {
    return div(classes: 'ct-field', styles: Styles(raw: {'margin-bottom': '10px'}), [
      Component.element(
        tag: 'label',
        attributes: {'for': id},
        children: [Component.text(label)],
      ),
      Component.element(
        tag: 'textarea',
        attributes: {
          'id': id,
          'name': id,
          'rows': '5',
          'required': '',
        },
        events: {
          'input': (e) => onInput(((e as dynamic).target.value as String?) ?? ''),
        },
        children: [Component.text(value)],
      ),
    ]);
  }
}
