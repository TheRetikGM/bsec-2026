import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';

class HistoryPanel extends ConsumerStatefulWidget {
  const HistoryPanel({super.key});

  @override
  ConsumerState<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends ConsumerState<HistoryPanel> {
  final _yt = TextEditingController();
  final _tt = TextEditingController();
  final _ig = TextEditingController();

  @override
  void dispose() {
    _yt.dispose();
    _tt.dispose();
    _ig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                tooltip: 'Import JSON',
                icon: const Icon(Icons.file_open),
                onPressed: () async {
                  await ref.read(historyProvider.notifier).importFromJsonFile();
                },
              ),
              IconButton(
                tooltip: 'Export JSON',
                icon: const Icon(Icons.save_alt),
                onPressed: () async {
                  await ref.read(historyProvider.notifier).exportToJsonFile();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Fetch history by username',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _yt,
            decoration: const InputDecoration(
              labelText: 'YouTube username',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tt,
            decoration: const InputDecoration(
              labelText: 'TikTok username',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ig,
            decoration: const InputDecoration(
              labelText: 'Instagram username',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () async {
              final api = ref.read(apiClientProvider);
              final items = await api.fetchHistoryByUsernames(
                youtube: _yt.text.trim(),
                tiktok: _tt.text.trim(),
                instagram: _ig.text.trim(),
              );
              await ref.read(historyProvider.notifier).mergeMany(items);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fetched ${items.length} items.')),
                );
              }
            },
            icon: const Icon(Icons.cloud_download),
            label: const Text('Fetch'),
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 6),
          const Text('Newest', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          historyAsync.when(
            data: (items) {
              if (items.isEmpty) return const Text('No history yet.');
              final newest = items.take(8).toList();
              return Column(
                children: newest.map((h) {
                  return Card(
                    child: ListTile(
                      dense: true,
                      title: Text(
                        h.selectedTopicTitle.isEmpty ? '(no topic)' : h.selectedTopicTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${h.createdAt.toLocal()} • attachments: ${h.attachmentCount}'
                        '${h.story == null ? '' : ' • story ✅'}'
                        '${h.outputs == null ? '' : ' • posts ✅'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              await ref.read(historyProvider.notifier).clear();
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear local history'),
          ),
        ],
      ),
    );
  }
}
