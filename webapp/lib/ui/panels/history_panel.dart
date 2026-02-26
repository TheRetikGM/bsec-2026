import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';
import '../../services/story_gen_service.dart';
import '../pages/history_detail_page.dart';
import '../widgets/animated_dots_text.dart';

class HistoryPanel extends ConsumerStatefulWidget {
  const HistoryPanel({super.key});

  @override
  ConsumerState<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends ConsumerState<HistoryPanel> {
  final _yt = TextEditingController();
  final _tt = TextEditingController();
  final _ig = TextEditingController();

  bool _submittingHistory = false;

  String _fmtDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

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
                child: Text('History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                tooltip: 'Clear local history',
                icon: const Icon(Icons.delete_outline),
                onPressed: _submittingHistory
                    ? null
                    : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear history?'),
                            content: const Text('This removes locally saved history.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Clear')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await ref.read(historyProvider.notifier).clear();
                        }
                      },
              ),
              IconButton(
                tooltip: 'Import JSON',
                icon: const Icon(Icons.file_open),
                onPressed: _submittingHistory
                    ? null
                    : () async {
                        try {
                          await ref.read(historyProvider.notifier).importFromJsonFile();
                          final histories = ref.read(historyProvider).value ?? const [];

                          if (histories.isEmpty) return;

                          setState(() => _submittingHistory = true);

                          if (context.mounted) {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => AlertDialog(
                                title: const Text('Submitting history'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    AnimatedDotsText('History is being processed by API'),
                                    SizedBox(height: 12),
                                    LinearProgressIndicator(),
                                  ],
                                ),
                              ),
                            );
                          }

                          await ref.read(storyGenServiceProvider).submitHistory(histories);

                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('History submitted.')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.of(context, rootNavigator: true).maybePop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Import/submit failed: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _submittingHistory = false);
                        }
                      },
              ),
              IconButton(
                tooltip: 'Export JSON',
                icon: const Icon(Icons.save_alt),
                onPressed: () async {
                  // await ref.read(historyProvider.notifier).exportToJsonFile();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Fetch history by username', style: TextStyle(fontWeight: FontWeight.w600)),
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
              try {
                final items = await ref.read(storyGenServiceProvider).fetchHistoryByUsernames(
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
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fetch failed: $e')),
                  );
                }
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
              final newest = items.take(12).toList();
              return Column(
                children: newest
                    .map((h) => Card(
                          child: ListTile(
                            dense: true,
                            title: Text(
                              h.topic.isEmpty ? '(no topic)' : h.topic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(_fmtDate(h.date)),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => HistoryDetailPage(item: h)),
                              );
                            },
                          ),
                        ))
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
