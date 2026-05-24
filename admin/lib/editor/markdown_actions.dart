import 'package:flutter/material.dart';

/// Insertions for the markdown toolbar. Each call mutates the controller's
/// text + selection so the cursor lands in a useful spot after the edit.
class MarkdownActions {
  MarkdownActions._();

  static void wrapInline(TextEditingController c, String token) {
    final sel = c.selection;
    final text = c.text;
    if (!sel.isValid) return;
    if (sel.isCollapsed) {
      final inserted = '$token$token';
      final newText = text.replaceRange(sel.start, sel.end, inserted);
      c.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start + token.length),
      );
    } else {
      final selected = text.substring(sel.start, sel.end);
      final inserted = '$token$selected$token';
      final newText = text.replaceRange(sel.start, sel.end, inserted);
      c.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: sel.start + token.length,
          extentOffset: sel.end + token.length,
        ),
      );
    }
  }

  static void bold(TextEditingController c) => wrapInline(c, '**');
  static void italic(TextEditingController c) => wrapInline(c, '_');
  static void code(TextEditingController c) => wrapInline(c, '`');

  static void heading(TextEditingController c) {
    final sel = c.selection;
    final text = c.text;
    if (!sel.isValid) return;
    final lineStart = _lineStart(text, sel.start);
    final prefix = '## ';
    // Toggle off if already present
    if (text.startsWith(prefix, lineStart)) {
      final newText = text.replaceRange(lineStart, lineStart + prefix.length, '');
      c.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start - prefix.length),
      );
      return;
    }
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    c.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.start + prefix.length),
    );
  }

  static void list(TextEditingController c) {
    final sel = c.selection;
    final text = c.text;
    if (!sel.isValid) return;
    final lineStart = _lineStart(text, sel.start);
    const prefix = '- ';
    if (text.startsWith(prefix, lineStart)) {
      final newText = text.replaceRange(lineStart, lineStart + prefix.length, '');
      c.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start - prefix.length),
      );
      return;
    }
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    c.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: sel.start + prefix.length),
    );
  }

  static void link(TextEditingController c) {
    final sel = c.selection;
    final text = c.text;
    if (!sel.isValid) return;
    if (sel.isCollapsed) {
      const inserted = '[](https://)';
      final newText = text.replaceRange(sel.start, sel.end, inserted);
      c.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start + 1),
      );
    } else {
      final selected = text.substring(sel.start, sel.end);
      final inserted = '[$selected](https://)';
      final newText = text.replaceRange(sel.start, sel.end, inserted);
      // Place cursor inside the URL slot
      final urlStart = sel.start + selected.length + 3;
      c.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: urlStart + 'https://'.length),
      );
    }
  }

  static int _lineStart(String text, int pos) {
    final idx = text.lastIndexOf('\n', pos - 1);
    return idx + 1;
  }
}
