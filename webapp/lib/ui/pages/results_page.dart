import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state.dart';

class ResultsPage extends ConsumerWidget {
  final VoidCallback onBackToTopics;
  const ResultsPage({super.key, required this.onBackToTopics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outputsAsync = ref.watch(outputsProvider);
    final topic = ref.watch(editableTopicProvider);
    final promptText = ref.watch(promptTextProvider);
    final attachmentCount = ref.watch(promptAttachmentsProvider).length;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to topics',
                onPressed: onBackToTopics,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              TextButton.icon(
                onPressed: outputsAsync.isLoading
                    ? null
                    : () async {
                        await ref.read(outputsProvider.notifier).generate();
                      },
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: outputsAsync.when(
              data: (out) {
                if (out == null) {
                  return const Center(
                      child: Text('No outputs yet. Go back and generate.'));
                }

                // Save to history when outputs appear
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final id = 'h_${DateTime.now().millisecondsSinceEpoch}';
                  final item = HistoryItem(
                    id: id,
                    createdAt: DateTime.now(),
                    promptText: promptText,
                    attachmentCount: attachmentCount,
                    selectedTopicTitle: topic?.title ?? '',
                    outputs: out,
                  );
                  await ref.read(historyProvider.notifier).add(item);
                });

                return ListView(
                  children: [
                    _OutputCard(title: 'YouTube', text: out.youtube),
                    const SizedBox(height: 12),
                    _OutputCard(title: 'TikTok', text: out.tiktok),
                    const SizedBox(height: 12),
                    _OutputCard(title: 'Telegram', text: out.telegram),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutputCard extends StatelessWidget {
  final String title;
  final String text;

  const _OutputCard({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final ctrl = TextEditingController(text: text);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800))),
              IconButton(
                tooltip: 'Copy',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied.')),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            minLines: 8,
            maxLines: 18,
            readOnly: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ]),
      ),
    );
  }
}
