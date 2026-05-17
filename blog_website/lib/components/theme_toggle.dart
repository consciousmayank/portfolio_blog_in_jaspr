import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class ThemeToggle extends StatefulComponent {
  const ThemeToggle({super.key});

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> {
  String _theme = 'editorial';

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      Document.html(attributes: {
        'data-theme': _theme,
        'data-accent': 'plum',
        'data-density': 'comfy',
      }),
      Component.element(
        tag: 'button',
        classes: 'nav-toggle',
        events: {'click': (_) => _toggle()},
        children: [.text(_theme == 'editorial' ? '◐ terminal' : '◑ editorial')],
      ),
    ]);
  }

  void _toggle() {
    setState(() {
      _theme = _theme == 'editorial' ? 'terminal' : 'editorial';
    });
  }
}
