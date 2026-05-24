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
  String _hp = '';
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
      attributes: const {'novalidate': ''},
      events: {
        'submit': (event) {
          (event as dynamic).preventDefault();
          _submit();
        },
      },
      children: [
        div(classes: 'ct-form-head', [.text('// say hello')]),
        // Name + email — two columns on wide screens, stacks on narrow
        Component.element(
          tag: 'div',
          classes: 'ct-row',
          children: [
            _field(
              id: 'cf-name',
              label: 'Your name',
              type: 'text',
              value: _name,
              autocomplete: 'name',
              onInput: (v) => setState(() => _name = v),
            ),
            _field(
              id: 'cf-email',
              label: 'Email',
              type: 'email',
              value: _email,
              autocomplete: 'email',
              onInput: (v) => setState(() => _email = v),
            ),
          ],
        ),
        _field(
          id: 'cf-subject',
          label: 'Subject',
          type: 'text',
          value: _subject,
          onInput: (v) => setState(() => _subject = v),
        ),
        _textarea(
          id: 'cf-message',
          label: 'Message',
          value: _message,
          onInput: (v) => setState(() => _message = v),
        ),
        // Honeypot — visually hidden via CSS .ct-hp; bots fill it, humans don't
        div(classes: 'ct-hp', attributes: const {'aria-hidden': 'true'}, [
          Component.element(
            tag: 'label',
            attributes: const {'for': 'cf-hp'},
            children: [Component.text('Leave this field empty')],
          ),
          Component.element(
            tag: 'input',
            attributes: {
              'id': 'cf-hp',
              'name': 'hp',
              'type': 'text',
              'autocomplete': 'off',
              'tabindex': '-1',
              'value': _hp,
            },
            events: {
              'input': (e) => setState(
                  () => _hp = ((e as dynamic).target.value as String?) ?? ''),
            },
          ),
        ]),
        if (_error != null)
          div(classes: 'ct-error', [.text(_error!)]),
        div(classes: 'ct-actions', [
          Component.element(
            tag: 'button',
            classes: 'ct-submit',
            attributes: {
              'type': 'submit',
              if (_submitting) 'disabled': '',
            },
            children: [
              Component.text(_submitting ? 'Sending…' : 'Send message'),
              span(styles: Styles(raw: {'font-family': 'var(--f-mono)'}), [.text('→')]),
            ],
          ),
          span(classes: 'ct-meta', [
            .text('replies usually within a day'),
          ]),
        ]),
      ],
    );
  }

  Component _success() {
    return div(classes: 'ct-success', [
      div(classes: 'h', [
        span(classes: 'dot', [.text('✓')]),
        .text('Thanks — got it.'),
      ]),
      p([
        .text(
          "I read every message that comes through. Expect a reply from "
          "consciousmayank@gmail.com within a day or two.",
        ),
      ]),
    ]);
  }

  Component _field({
    required String id,
    required String label,
    required String type,
    required String value,
    required void Function(String) onInput,
    String? autocomplete,
  }) {
    return div(classes: 'ct-field', [
      Component.element(
        tag: 'label',
        classes: 'ct-label',
        attributes: {'for': id},
        children: [Component.text(label)],
      ),
      Component.element(
        tag: 'input',
        classes: 'ct-input',
        attributes: {
          'id': id,
          'name': id,
          'type': type,
          'value': value,
          if (autocomplete != null) 'autocomplete': autocomplete,
          'required': '',
        },
        events: {
          'input': (e) =>
              onInput(((e as dynamic).target.value as String?) ?? ''),
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
    return div(classes: 'ct-field', [
      Component.element(
        tag: 'label',
        classes: 'ct-label',
        attributes: {'for': id},
        children: [Component.text(label)],
      ),
      Component.element(
        tag: 'textarea',
        classes: 'ct-textarea',
        attributes: {
          'id': id,
          'name': id,
          'rows': '5',
          'required': '',
        },
        events: {
          'input': (e) =>
              onInput(((e as dynamic).target.value as String?) ?? ''),
        },
        children: [Component.text(value)],
      ),
    ]);
  }
}
