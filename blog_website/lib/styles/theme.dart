import 'package:jaspr/dom.dart';

// ── Design token constants ────────────────────────────────────────────────
const colorPrimary = Color('#0553B1');
const colorSecondary = Color('#00BCD4');
const colorBg = Color('#0f1117');
const colorBgLight = Color('#ffffff');
const colorText = Color('#e2e8f0');
const colorTextLight = Color('#1a202c');
const colorSurface = Color('#1e2130');
const colorSurfaceLight = Color('#f0f4f8');
const colorBorder = Color('#2d3348');
const colorBorderLight = Color('#cbd5e0');
const colorMuted = Color('#718096');
const colorAccentHover = Color('#0668cc');

// ── Global design-system styles ──────────────────────────────────────────
// Included manually in main.server.dart Document(styles: [...])
List<StyleRule> get designSystemStyles => [
  // Google Fonts
  css.import(
    'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Fira+Code:wght@400;500&display=swap',
  ),

  // ── Resets & base ────────────────────────────────────────────────────
  css('*, *::before, *::after').styles(
    boxSizing: .borderBox,
  ),

  css('html').styles(
    color: colorText,
    backgroundColor: colorBg,
  ),

  css('html.dark').styles(
    color: colorText,
    backgroundColor: colorBg,
  ),

  css('html.light').styles(
    color: colorTextLight,
    backgroundColor: colorBgLight,
  ),

  css('html, body').styles(
    width: 100.percent,
    minHeight: 100.vh,
    padding: .zero,
    margin: .zero,
    fontFamily: const .list([FontFamily('Inter'), FontFamilies.sansSerif]),
  ),

  css('h1, h2, h3, h4, h5, h6').styles(
    margin: .unset,
    fontWeight: .w700,
  ),

  css('a').styles(
    color: colorPrimary,
    textDecoration: TextDecoration(line: .none),
  ),

  css('a:hover').styles(
    color: colorAccentHover,
    textDecoration: TextDecoration(line: .underline),
  ),

  css('img').styles(
    maxWidth: 100.percent,
    height: .auto,
  ),

  css('code, pre').styles(
    fontFamily: const .list([FontFamily('Fira Code'), FontFamilies.monospace]),
  ),

  // ── Layout utilities ─────────────────────────────────────────────────
  css('.container').styles(
    maxWidth: 1100.px,
    margin: .symmetric(horizontal: .auto),
    padding: .symmetric(horizontal: 1.5.rem),
  ),

  css('.section').styles(
    padding: .symmetric(vertical: 4.rem),
  ),

  css('.section-title').styles(
    fontSize: 1.75.rem,
    fontWeight: .w700,
    color: colorPrimary,
    position: .relative(),
    margin: .only(bottom: 1.5.rem),
  ),

  // ── Card ─────────────────────────────────────────────────────────────
  css('.card').styles(
    backgroundColor: colorSurface,
    radius: .all(.circular(8.px)),
    padding: .all(1.5.rem),
    border: .symmetric(
      vertical: .solid(color: colorBorder, width: 1.px),
      horizontal: .solid(color: colorBorder, width: 1.px),
    ),
    transition: Transition('transform', duration: 200.ms, curve: .ease),
  ),

  css('.card:hover').styles(
    border: .symmetric(
      vertical: .solid(color: colorPrimary, width: 1.px),
      horizontal: .solid(color: colorPrimary, width: 1.px),
    ),
  ),

  css('html.light .card').styles(
    backgroundColor: colorSurfaceLight,
    border: .symmetric(
      vertical: .solid(color: colorBorderLight, width: 1.px),
      horizontal: .solid(color: colorBorderLight, width: 1.px),
    ),
  ),

  // ── Buttons ───────────────────────────────────────────────────────────
  css('.btn').styles(
    display: .inlineFlex,
    alignItems: .center,
    fontWeight: .w600,
    cursor: .pointer,
    textDecoration: TextDecoration(line: .none),
    border: .symmetric(
      vertical: .solid(color: Colors.transparent, width: 2.px),
      horizontal: .solid(color: Colors.transparent, width: 2.px),
    ),
    radius: .all(.circular(6.px)),
    fontSize: 0.95.rem,
    transition: Transition('all', duration: 200.ms, curve: .ease),
    padding: .symmetric(horizontal: 1.25.rem, vertical: 0.65.rem),
  ),

  css('.btn-primary').styles(
    backgroundColor: colorPrimary,
    color: Colors.white,
  ),

  css('.btn-primary:hover').styles(
    backgroundColor: colorAccentHover,
  ),

  css('.btn-outline').styles(
    backgroundColor: Colors.transparent,
    color: colorSecondary,
    border: .symmetric(
      vertical: .solid(color: colorSecondary, width: 2.px),
      horizontal: .solid(color: colorSecondary, width: 2.px),
    ),
  ),

  css('.btn-outline:hover').styles(
    backgroundColor: colorSecondary,
    color: Colors.white,
  ),

  css('.btn-ghost').styles(
    backgroundColor: Colors.transparent,
    color: colorText,
    border: .symmetric(
      vertical: .solid(color: colorBorder, width: 2.px),
      horizontal: .solid(color: colorBorder, width: 2.px),
    ),
  ),

  css('.btn-ghost:hover').styles(
    color: colorPrimary,
    border: .symmetric(
      vertical: .solid(color: colorPrimary, width: 2.px),
      horizontal: .solid(color: colorPrimary, width: 2.px),
    ),
  ),

  css('html.light .btn-ghost').styles(
    color: colorTextLight,
    border: .symmetric(
      vertical: .solid(color: colorBorderLight, width: 2.px),
      horizontal: .solid(color: colorBorderLight, width: 2.px),
    ),
  ),

  // ── Muted text ────────────────────────────────────────────────────────
  css('.text-muted').styles(
    color: colorMuted,
  ),

  css('.text-secondary').styles(
    color: colorSecondary,
  ),

  css('.text-primary').styles(
    color: colorPrimary,
  ),
];
