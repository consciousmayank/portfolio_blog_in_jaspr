import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _baseUrl = TextEditingController();
  String? _error;
  bool _showBaseUrl = false;

  @override
  void initState() {
    super.initState();
    _baseUrl.text = ref.read(apiBaseUrlProvider);
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    try {
      if (_baseUrl.text.trim().isNotEmpty &&
          _baseUrl.text.trim() != ref.read(apiBaseUrlProvider)) {
        await ref.read(authControllerProvider.notifier).setBaseUrl(_baseUrl.text.trim());
      }
      await ref.read(authControllerProvider.notifier).login(
            _email.text.trim(),
            _password.text,
          );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Portfolio admin',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _showBaseUrl = !_showBaseUrl),
                      child: Text(_showBaseUrl ? 'Hide API URL' : 'Change API URL'),
                    ),
                  ],
                ),
                if (_showBaseUrl)
                  TextField(
                    controller: _baseUrl,
                    decoration: const InputDecoration(
                      labelText: 'API base URL',
                      hintText: 'https://mayankjoshi.in',
                    ),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: auth.loading ? null : _submit,
                  child: auth.loading
                      ? const SizedBox(
                          height: 16, width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
