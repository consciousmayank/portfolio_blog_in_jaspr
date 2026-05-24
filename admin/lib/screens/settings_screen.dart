import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../auth/auth.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_chip.dart';
import '../widgets/eyebrow.dart';

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
  PackageInfo? _info;
  String? _error;
  String? _info_msg;
  String? _reachStatus;
  Duration? _reachLatency;

  @override
  void initState() {
    super.initState();
    _baseUrl.text = ref.read(apiBaseUrlProvider);
    PackageInfo.fromPlatform().then((i) => mounted ? setState(() => _info = i) : null);
  }

  Future<void> _savePassword() async {
    setState(() {
      _error = null;
      _info_msg = null;
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
        _info_msg = 'Password updated.';
        _current.clear();
        _next.clear();
        _confirm.clear();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _testReach() async {
    setState(() {
      _reachStatus = 'pinging';
      _reachLatency = null;
    });
    final api = ref.read(apiClientProvider);
    final started = DateTime.now();
    try {
      // Hits /health which is public, no auth.
      await api.listBlog(); // any authenticated call also confirms token works
      setState(() {
        _reachStatus = 'reachable';
        _reachLatency = DateTime.now().difference(started);
      });
    } catch (e) {
      setState(() {
        _reachStatus = 'unreachable';
        _reachLatency = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: DesignAppBar(
        title: 'Settings',
        eyebrow: 'preferences',
        eyebrowNumber: '06',
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 24),
          onPressed: () => context.go('/blog'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
        children: [
          _sectionHead(context, '01', 'Account'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const _Label('EMAIL'),
              TextField(
                readOnly: true,
                controller: TextEditingController(text: 'consciousmayank@gmail.com'),
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 14),
              const _Label('CHANGE PASSWORD'),
              TextField(controller: _current, decoration: const InputDecoration(hintText: 'Current password'), obscureText: true),
              const SizedBox(height: 8),
              TextField(controller: _next, decoration: const InputDecoration(hintText: 'New password'), obscureText: true),
              const SizedBox(height: 8),
              TextField(controller: _confirm, decoration: const InputDecoration(hintText: 'Confirm'), obscureText: true),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: t.danger, fontSize: 12.5)),
              ],
              if (_info_msg != null) ...[
                const SizedBox(height: 8),
                Text(_info_msg!, style: TextStyle(color: t.success, fontSize: 12.5)),
              ],
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _savePassword,
                child: const Text('Update password'),
              ),
            ]),
          ),
          _sectionHead(context, '02', 'API endpoint'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const _Label('BASE URL'),
              TextField(
                controller: _baseUrl,
                autocorrect: false,
                enableSuggestions: false,
                style: AppText.mono(context, size: 12.5).copyWith(color: t.ink),
              ),
              const SizedBox(height: 6),
              Text(
                'Used for all admin reads and writes. Restart not required.',
                style: AppText.mono(context, size: 11, color: t.ink3),
              ),
              const SizedBox(height: 10),
              Row(children: [
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).setBaseUrl(_baseUrl.text.trim());
                    if (!mounted) return;
                    final m = ScaffoldMessenger.of(context);
                    m.showSnackBar(const SnackBar(content: Text('Saved.')));
                  },
                  child: const Text('Save URL'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _testReach,
                  child: const Text('Test reach'),
                ),
                const SizedBox(width: 8),
                if (_reachStatus == 'reachable')
                  StatusChip(
                    label: 'reachable · ${_reachLatency?.inMilliseconds}ms',
                    kind: ChipKind.success,
                  )
                else if (_reachStatus == 'unreachable')
                  const StatusChip(label: 'unreachable', kind: ChipKind.danger)
                else if (_reachStatus == 'pinging')
                  const StatusChip(label: 'pinging…', kind: ChipKind.warn),
              ]),
            ]),
          ),
          _sectionHead(context, '03', 'About'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: DefaultTextStyle(
                  style: AppText.mono(context, size: 12, color: t.ink2).copyWith(height: 1.7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _aboutLine('build  ', '${_info?.version ?? '—'} · ${_info?.buildNumber ?? '—'}'),
                      _aboutLine('package', _info?.packageName ?? '—'),
                      _aboutLine('app    ', _info?.appName ?? '—'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: t.danger,
                  side: BorderSide(color: t.dangerSoft),
                ),
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (!mounted) return;
                  context.go('/login');
                },
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Sign out'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHead(BuildContext context, String num, String title) {
    final t = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(number: num, label: 'section'),
          const SizedBox(height: 4),
          Text(title, style: AppText.serif(context, size: 22).copyWith(color: t.ink)),
        ],
      ),
    );
  }

  Widget _aboutLine(String label, String value) {
    final t = AppTokens.of(context);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: AppText.mono(context, size: 12, color: t.ink4).copyWith(height: 1.7),
          ),
          TextSpan(
            text: value,
            style: AppText.mono(context, size: 12, color: t.ink2).copyWith(height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: AppText.label(context)),
      );
}
