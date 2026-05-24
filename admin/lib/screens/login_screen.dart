import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/eyebrow.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _baseUrl = TextEditingController();
  bool _showBaseUrl = false;
  bool _obscure = true;
  String? _error;

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
        await ref
            .read(authControllerProvider.notifier)
            .setBaseUrl(_baseUrl.text.trim());
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
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 38, 28, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Eyebrow(number: '00', label: 'workshop'),
                  const SizedBox(height: 18),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: 'Welcome back, ',
                          style: AppText.serif(context, size: 44).copyWith(
                            height: 0.98, letterSpacing: -0.66,
                          )),
                      TextSpan(
                          text: 'Mayank.',
                          style: AppText.serif(context, size: 44, italic: true).copyWith(
                            height: 0.98, letterSpacing: -0.66,
                          )),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in to the back room. The public site reads from '
                    'whatever you publish here.',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: t.ink3,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 42),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'EMAIL'),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'PASSWORD',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: auth.loading ? null : _submit,
                      child: auth.loading
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Open up'),
                                SizedBox(width: 6),
                                Icon(Icons.chevron_right, size: 16),
                              ],
                            ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(color: t.danger, fontSize: 12.5)),
                  ],
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => setState(() => _showBaseUrl = !_showBaseUrl),
                      child: Text(
                        _showBaseUrl ? 'Hide API URL' : 'Change API URL',
                        style: AppText.mono(
                          context, size: 12,
                          color: t.ink3,
                        ).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: t.ink3,
                        ),
                      ),
                    ),
                  ),
                  if (_showBaseUrl) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _baseUrl,
                      decoration: const InputDecoration(
                        labelText: 'API BASE URL',
                        hintText: 'https://mayankjoshi.in',
                      ),
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                  ],
                  const SizedBox(height: 28),
                  Text(
                    'v 0.1.0 · admin · mayankjoshi.in',
                    style: AppText.mono(context, size: 11, color: t.ink4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
