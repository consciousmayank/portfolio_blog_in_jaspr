import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

const _phrases = [
  'ship a Flutter web POS for 50K merchants',
  'wire BLoC + FastAPI in an afternoon',
  'review a PR with Claude before lunch',
  'port a native Android app to Flutter in 3 weeks',
  'scaffold a Next.js admin from a Figma in one sitting',
  'write the tests AI forgot to write',
];

@client
class HeroTypewriter extends StatefulComponent {
  const HeroTypewriter({super.key});

  @override
  State<HeroTypewriter> createState() => _HeroTypewriterState();
}

class _HeroTypewriterState extends State<HeroTypewriter> {
  int _phraseIdx = 0;
  String _shown = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _startTyping();
    }
  }

  void _startTyping() {
    final phrase = _phrases[_phraseIdx];
    var i = 0;
    _shown = '';

    _timer?.cancel();
    tick() {
      if (i <= phrase.length) {
        setState(() => _shown = phrase.substring(0, i));
        i++;
        _timer = Timer(Duration(milliseconds: 28 + (DateTime.now().millisecond % 30)), tick);
      } else {
        _timer = Timer(const Duration(milliseconds: 1800), () {
          setState(() {
            _phraseIdx = (_phraseIdx + 1) % _phrases.length;
          });
          _startTyping();
        });
      }
    }

    tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return span(classes: 'typer', [
      .text(_shown),
      span(classes: 'caret', []),
    ]);
  }
}
