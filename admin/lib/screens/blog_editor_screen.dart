import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../api/models.dart';
import '../auth/auth.dart';

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
  final _titleC = TextEditingController();
  final _slugC = TextEditingController();
  final _descC = TextEditingController();
  final _bodyC = TextEditingController();
  final _coverC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ref.read(apiClientProvider);
    if (widget.slug == null) {
      _post = BlogPost(
        slug: '',
        title: '',
        date: DateTime.now(),
        tags: [],
        description: '',
      );
    } else {
      _post = await api.getBlog(widget.slug!);
    }
    _titleC.text = _post.title;
    _slugC.text = _post.slug;
    _descC.text = _post.description;
    _bodyC.text = _post.bodyMarkdown;
    _coverC.text = _post.cover ?? '';
    setState(() => _loading = false);
  }

  String _slugify(String v) => v
      .toLowerCase()
      .trim()
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
      if (mounted) context.go('/blog');
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
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton.tonal(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
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
    if (picked != null) setState(() => _post.date = picked);
  }

  Future<void> _pickCover() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
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
    setState(() => _coverC.text = url);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final wide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.slug == null ? 'New post' : 'Edit · ${widget.slug}'),
        actions: [
          if (widget.slug != null)
            IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleC,
            decoration: const InputDecoration(labelText: 'Title'),
            onChanged: (v) {
              if (widget.slug == null && _slugC.text.isEmpty) {
                _slugC.text = _slugify(v);
              }
            },
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _slugC,
                decoration: const InputDecoration(labelText: 'Slug'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                  '${_post.date.year}-${_post.date.month.toString().padLeft(2, '0')}-${_post.date.day.toString().padLeft(2, '0')}'),
            ),
            const SizedBox(width: 12),
            Switch(
              value: _post.published,
              onChanged: (v) => setState(() => _post.published = v),
            ),
            const Text('Published'),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _descC,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          _tags(),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _coverC,
                decoration: const InputDecoration(labelText: 'Cover image URL'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(onPressed: _pickCover, icon: const Icon(Icons.upload)),
          ]),
          const SizedBox(height: 20),
          if (wide)
            SizedBox(
              height: 700,
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: _editor()),
                const SizedBox(width: 12),
                Expanded(child: _preview()),
              ]),
            )
          else ...[
            SizedBox(height: 400, child: _editor()),
            const SizedBox(height: 12),
            SizedBox(height: 400, child: _preview()),
          ],
        ],
      ),
    );
  }

  Widget _editor() => TextField(
        controller: _bodyC,
        maxLines: null,
        expands: true,
        decoration: const InputDecoration(
          labelText: 'Markdown',
          border: OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      );

  Widget _preview() => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(12),
        child: Markdown(
          data: _bodyC.text,
          selectable: true,
          onTapLink: (_, href, __) {},
        ),
      );

  Widget _tags() {
    return InputDecorator(
      decoration: const InputDecoration(labelText: 'Tags', border: OutlineInputBorder()),
      child: Wrap(
        spacing: 6, runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ..._post.tags.map((t) => Chip(
                label: Text(t),
                onDeleted: () => setState(() => _post.tags.remove(t)),
              )),
          SizedBox(
            width: 160,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'add tag, press Enter',
                border: InputBorder.none, isDense: true,
              ),
              onSubmitted: (v) {
                final t = v.trim();
                if (t.isNotEmpty && !_post.tags.contains(t)) {
                  setState(() => _post.tags.add(t));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
