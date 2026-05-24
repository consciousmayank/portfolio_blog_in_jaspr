import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../api/models.dart';
import '../auth/auth.dart';
import '../editor/markdown_actions.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/app_chip.dart';
import '../widgets/eyebrow.dart';

class BlogEditorScreen extends ConsumerStatefulWidget {
  const BlogEditorScreen({required this.slug, super.key});
  final String? slug;

  @override
  ConsumerState<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends ConsumerState<BlogEditorScreen> {
  late BlogPost _post;
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  bool _detailsOpen = false;

  final _titleC = TextEditingController();
  final _slugC = TextEditingController();
  final _descC = TextEditingController();
  final _bodyC = TextEditingController();
  final _coverC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _detailsOpen = widget.slug == null;
    _load();
    for (final c in [_titleC, _slugC, _descC, _bodyC, _coverC]) {
      c.addListener(() {
        if (!_dirty) setState(() => _dirty = true);
      });
    }
  }

  @override
  void dispose() {
    _titleC.dispose();
    _slugC.dispose();
    _descC.dispose();
    _bodyC.dispose();
    _coverC.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final api = ref.read(apiClientProvider);
    if (widget.slug == null) {
      _post = BlogPost(
        slug: '', title: '', date: DateTime.now(),
        tags: [], description: '',
      );
    } else {
      _post = await api.getBlog(widget.slug!);
    }
    _titleC.text = _post.title;
    _slugC.text = _post.slug;
    _descC.text = _post.description;
    _bodyC.text = _post.bodyMarkdown;
    _coverC.text = _post.cover ?? '';
    if (mounted) setState(() {
      _loading = false;
      _dirty = false;
    });
  }

  String _slugify(String v) => v.toLowerCase().trim()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  Future<void> _save() async {
    setState(() => _saving = true);
    final api = ref.read(apiClientProvider);
    _post
      ..title = _titleC.text.trim()
      ..slug = _slugC.text.trim().isEmpty ? _slugify(_titleC.text) : _slugC.text.trim()
      ..description = _descC.text
      ..bodyMarkdown = _bodyC.text
      ..cover = _coverC.text.trim().isEmpty ? null : _coverC.text.trim();
    try {
      if (widget.slug == null) {
        await api.createBlog(_post);
      } else {
        await api.updateBlog(widget.slug!, _post);
      }
      if (mounted) {
        setState(() => _dirty = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved.')),
        );
        context.go('/blog');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.slug == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final t = AppTokens.of(ctx);
        return AlertDialog(
          title: const Text('Delete this post permanently?'),
          content: Text('It will disappear from the public site immediately.',
              style: TextStyle(color: t.ink2)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: t.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (ok != true) return;
    await ref.read(apiClientProvider).deleteBlog(widget.slug!);
    if (mounted) context.go('/blog');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _post.date,
      firstDate: DateTime(2014),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() {
      _post.date = picked;
      _dirty = true;
    });
  }

  Future<void> _pickCover() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image, withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    if (file.bytes == null) return;
    final api = ref.read(apiClientProvider);
    final url = await api.uploadMedia(
      bytes: file.bytes!,
      filename: file.name,
      slug: _slugC.text.trim().isEmpty ? null : _slugC.text.trim(),
    );
    setState(() {
      _coverC.text = url;
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final t = AppTokens.of(context);
    final wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/blog'),
          icon: const Icon(Icons.chevron_left, size: 24),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Text(widget.slug == null ? 'EDIT' : 'EDIT',
                  style: AppText.eyebrow(context)),
              const SizedBox(width: 8),
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dirty ? t.accent : t.success,
                ),
              ),
              const SizedBox(width: 6),
              Text(_dirty ? 'unsaved' : 'saved',
                  style: AppText.mono(context, size: 10, color: t.ink3)),
            ]),
            const SizedBox(height: 2),
            Text(
              _titleC.text.isEmpty ? 'New post' : _titleC.text,
              style: AppText.serif(context, size: 18),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          if (widget.slug != null)
            IconButton(
              onPressed: _delete,
              icon: Icon(Icons.delete_outline, size: 18, color: t.danger),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 12, 0),
            child: SizedBox(
              height: 28,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(fontSize: 12.5),
                ),
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save'),
              ),
            ),
          ),
        ],
      ),
      body: wide ? _wide(t) : _narrow(t),
    );
  }

  // ── Narrow (phone) layout ─────────────────────────────────────────────
  Widget _narrow(AppTokens t) {
    return Column(
      children: [
        _detailsCard(t),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'INPUT'),
                    Tab(text: 'OUTPUT'),
                  ],
                ),
                _toolbar(t),
                Expanded(
                  child: TabBarView(
                    children: [
                      _editor(t),
                      _preview(t),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Wide (tablet/desktop) layout: input + preview side by side ────────
  Widget _wide(AppTokens t) {
    return Column(children: [
      _detailsStrip(t),
      Expanded(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: Column(children: [
              _toolbar(t, wide: true),
              Expanded(child: _editor(t)),
            ]),
          ),
          VerticalDivider(width: 1, color: t.borderSoft),
          Expanded(
            child: Column(children: [
              Container(
                color: t.bg2,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                width: double.infinity,
                child: Eyebrow(label: 'output  ·  rendered'),
              ),
              Divider(height: 1, color: t.borderSoft),
              Expanded(child: _preview(t)),
            ]),
          ),
        ]),
      ),
    ]);
  }

  // ── Collapsible details on phone ──────────────────────────────────────
  Widget _detailsCard(AppTokens t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          InkWell(
            onTap: () => setState(() => _detailsOpen = !_detailsOpen),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(children: [
                AnimatedRotation(
                  turns: _detailsOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(Icons.expand_more, size: 16, color: t.ink3),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow(label: 'post details'),
                      const SizedBox(height: 2),
                      Text(
                        '${_slugC.text.isEmpty ? "/blog/—" : "/blog/${_slugC.text}"} · ${DateFormat.yMMM().format(_post.date)} · ${_post.published ? "live" : "draft"}',
                        style: TextStyle(fontSize: 12.5, color: t.ink3),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppChip(
                  label: _post.published ? 'live' : 'draft',
                  kind: _post.published ? ChipKind.success : ChipKind.warn,
                  dense: true,
                ),
              ]),
            ),
          ),
          if (_detailsOpen) ...[
            Divider(height: 1, color: t.borderSoft),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: _metaFields(t),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _detailsStrip(AppTokens t) {
    return Container(
      color: t.bg2,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: _metaFields(t),
    );
  }

  Widget _metaFields(AppTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _titleC,
          decoration: const InputDecoration(labelText: 'TITLE'),
          onChanged: (v) {
            if (widget.slug == null && _slugC.text.isEmpty) {
              _slugC.text = _slugify(v);
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _slugC,
          decoration: const InputDecoration(labelText: 'SLUG'),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 14),
              label: Text(DateFormat.yMMMd().format(_post.date),
                  style: const TextStyle(fontSize: 12.5)),
            ),
          ),
          const SizedBox(width: 12),
          Row(children: [
            Text('Published', style: TextStyle(fontSize: 13, color: t.ink2)),
            const SizedBox(width: 8),
            Switch(
              value: _post.published,
              onChanged: (v) => setState(() {
                _post.published = v;
                _dirty = true;
              }),
            ),
          ]),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _descC,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'DESCRIPTION'),
        ),
        const SizedBox(height: 12),
        _tagsField(t),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _coverC,
              decoration: const InputDecoration(labelText: 'COVER IMAGE URL'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
              onPressed: _pickCover,
              icon: const Icon(Icons.upload_outlined, size: 18)),
        ]),
      ],
    );
  }

  Widget _tagsField(AppTokens t) {
    final addC = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TAGS', style: AppText.label(context)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Wrap(
            spacing: 6, runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in _post.tags)
                Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => setState(() {
                    _post.tags.remove(tag);
                    _dirty = true;
                  }),
                ),
              SizedBox(
                width: 160,
                child: TextField(
                  controller: addC,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'add tag, press Enter',
                  ),
                  autocorrect: false,
                  enableSuggestions: false,
                  onSubmitted: (v) {
                    final tag = v.trim();
                    if (tag.isEmpty || _post.tags.contains(tag)) return;
                    setState(() {
                      _post.tags.add(tag);
                      _dirty = true;
                    });
                    addC.clear();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toolbar(AppTokens t, {bool wide = false}) {
    Widget btn(IconData icon, VoidCallback action) => IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
          iconSize: 15,
          onPressed: action,
          icon: Icon(icon),
        );
    final wc = _bodyC.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return Container(
      decoration: BoxDecoration(
        color: wide ? t.bg2 : t.bg,
        border: Border(bottom: BorderSide(color: t.borderSoft)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(children: [
        if (wide) ...[
          Eyebrow(label: 'input  ·  md'),
          const SizedBox(width: 10),
        ],
        btn(Icons.format_bold, () => MarkdownActions.bold(_bodyC)),
        btn(Icons.format_italic, () => MarkdownActions.italic(_bodyC)),
        btn(Icons.title, () => MarkdownActions.heading(_bodyC)),
        btn(Icons.link, () => MarkdownActions.link(_bodyC)),
        btn(Icons.format_list_bulleted, () => MarkdownActions.list(_bodyC)),
        btn(Icons.code, () => MarkdownActions.code(_bodyC)),
        const Spacer(),
        Text('md · $wc w',
            style: AppText.mono(context, size: 10.5, color: t.ink4)),
      ]),
    );
  }

  Widget _editor(AppTokens t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: TextField(
        controller: _bodyC,
        maxLines: null,
        expands: true,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        enableSuggestions: false,
        smartDashesType: SmartDashesType.disabled,
        smartQuotesType: SmartQuotesType.disabled,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          hintText: 'Markdown here…',
          filled: false,
        ),
        style: AppText.mono(context, size: 12.5).copyWith(
          height: 1.55, color: t.ink,
        ),
      ),
    );
  }

  Widget _preview(AppTokens t) {
    return AnimatedBuilder(
      animation: _bodyC,
      builder: (_, __) {
        if (_bodyC.text.isEmpty) {
          return Center(
            child: Text('Nothing to preview yet.',
                style: TextStyle(color: t.ink3, fontStyle: FontStyle.italic)),
          );
        }
        return Markdown(
          data: _bodyC.text,
          selectable: true,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          styleSheet: _markdownStyle(t),
          onTapLink: (_, href, __) {},
        );
      },
    );
  }

  MarkdownStyleSheet _markdownStyle(AppTokens t) {
    return MarkdownStyleSheet(
      h1: AppText.serif(context, size: 28).copyWith(height: 1.05),
      h2: AppText.serif(context, size: 22).copyWith(height: 1.1),
      h3: AppText.serif(context, size: 18).copyWith(height: 1.2),
      p: TextStyle(fontSize: 14, height: 1.6, color: t.ink2),
      strong: TextStyle(fontWeight: FontWeight.w600, color: t.ink),
      em: TextStyle(fontStyle: FontStyle.italic, color: t.ink),
      code: AppText.mono(context, size: 12, color: t.codeInk).copyWith(
        backgroundColor: t.codeBg,
      ),
      codeblockDecoration: BoxDecoration(
        color: t.codeBg,
        borderRadius: BorderRadius.circular(4),
      ),
      codeblockPadding: const EdgeInsets.all(14),
      blockquote: TextStyle(color: t.ink3, fontStyle: FontStyle.italic),
      a: TextStyle(color: t.accent, decoration: TextDecoration.underline),
      listBullet: TextStyle(color: t.ink3),
    );
  }
}
