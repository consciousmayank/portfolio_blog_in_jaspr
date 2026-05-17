import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../utils/theme_storage.dart';

class _ThemeOption {
  final String id;
  final String label;
  final String desc;
  final String icon;
  final List<String> swatches;
  const _ThemeOption(this.id, this.label, this.desc, this.icon, this.swatches);
}

const _kThemes = [
  _ThemeOption('editorial', 'Editorial', 'Light · serif', '◐', ['#f0ebe0', '#e8e1d5', '#8a5a8c']),
  _ThemeOption('terminal', 'Terminal', 'Dark · mono', '▣', ['#14192c', '#18203a', '#6ba3d6']),
  _ThemeOption('glass', 'Glass', 'Frosted dark', '◈', ['#1a1232', '#201838', '#e260a0']),
  _ThemeOption('neon', 'Neon', 'Cyberpunk', '◉', ['#0d0b18', '#111424', '#f040a5']),
  _ThemeOption('minimal', 'Minimal', 'Monochrome', '○', ['#fcfcfc', '#f5f5f5', '#141414']),
  _ThemeOption('aurora', 'Aurora', 'Night sky', '◎', ['#0c1818', '#0e1d1e', '#3dcc70']),
];

@client
class ThemeToggle extends StatefulComponent {
  const ThemeToggle({super.key});

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> {
  String _theme = 'editorial';
  bool _open = false;

  @override
  void initState() {
    super.initState();
    final saved = getSavedTheme();
    if (saved != null && _kThemes.any((t) => t.id == saved)) {
      _theme = saved;
    }
  }

  void _select(String id) {
    saveTheme(id);
    setState(() {
      _theme = id;
      _open = false;
    });
  }

  @override
  Component build(BuildContext context) {
    final current = _kThemes.firstWhere(
      (t) => t.id == _theme,
      orElse: () => _kThemes.first,
    );
    return Component.fragment([
      Document.html(attributes: {
        'data-theme': _theme,
        'data-accent': 'plum',
        'data-density': 'comfy',
      }),
      div(classes: 'theme-chooser', [
        Component.element(
          tag: 'button',
          classes: 'nav-toggle',
          events: {'click': (_) => setState(() => _open = !_open)},
          children: [.text('${current.icon} ${current.label}')],
        ),
        if (_open) ...[
          Component.element(
            tag: 'div',
            classes: 'theme-overlay',
            events: {'click': (_) => setState(() => _open = false)},
            children: [],
          ),
          div(classes: 'theme-panel', [
            for (final t in _kThemes)
              Component.element(
                tag: 'button',
                classes: 'theme-option${_theme == t.id ? ' active' : ''}',
                events: {'click': (_) => _select(t.id)},
                children: [
                  div(classes: 'theme-option-swatches', [
                    for (final c in t.swatches)
                      div(
                        classes: 'theme-option-swatch',
                        styles: Styles(raw: {'background': c}),
                        [],
                      ),
                  ]),
                  span(classes: 'theme-option-label', [.text(t.label)]),
                  span(classes: 'theme-option-desc', [.text(t.desc)]),
                ],
              ),
          ]),
        ],
      ]),
    ]);
  }
}
