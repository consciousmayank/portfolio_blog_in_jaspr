import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  final _baseUrl = TextEditingController();
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _baseUrl.text = ref.read(apiBaseUrlProvider);
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _info = null;
    });
    if (_next.text.length < 12) {
      setState(() => _error = 'New password must be at least 12 characters.');
      return;
    }
    if (_next.text != _confirm.text) {
      setState(() => _error = 'Confirmation does not match.');
      return;
    }
    try {
      await ref.read(apiClientProvider).changePassword(_current.text, _next.text);
      setState(() {
        _info = 'Password updated.';
        _current.clear();
        _next.clear();
        _confirm.clear();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Change password', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(controller: _current, decoration: const InputDecoration(labelText: 'Current password'), obscureText: true),
        const SizedBox(height: 12),
        TextField(controller: _next, decoration: const InputDecoration(labelText: 'New password (min 12)'), obscureText: true),
        const SizedBox(height: 12),
        TextField(controller: _confirm, decoration: const InputDecoration(labelText: 'Confirm new password'), obscureText: true),
        if (_error != null) ...[const SizedBox(height: 8), Text(_error!, style: const TextStyle(color: Colors.redAccent))],
        if (_info != null) ...[const SizedBox(height: 8), Text(_info!, style: const TextStyle(color: Colors.green))],
        const SizedBox(height: 16),
        FilledButton(onPressed: _save, child: const Text('Update password')),
        const Divider(height: 48),
        Text('API base URL', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(controller: _baseUrl, decoration: const InputDecoration(labelText: 'API base URL')),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () async {
            await ref.read(authControllerProvider.notifier).setBaseUrl(_baseUrl.text.trim());
            if (!mounted) return;
            final messenger = ScaffoldMessenger.of(context);
            messenger.showSnackBar(const SnackBar(content: Text('Saved.')));
          },
          child: const Text('Save base URL'),
        ),
      ],
    );
  }
}
