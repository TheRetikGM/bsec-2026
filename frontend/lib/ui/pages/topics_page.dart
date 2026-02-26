import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state.dart';

class TopicsPage extends ConsumerWidget {
  final VoidCallback onBackToStart;
  final VoidCallback onNextToResults;

  const TopicsPage({
    super.key,
    required this.onBackToStart,
    required this.onNextToResults,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final selectedId = ref.watch(selectedTopicIdProvider);
    final editable = ref.watch(editableTopicProvider);
    final outputsAsync = ref.watch(outputsProvider);

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to start',
                onPressed: onBackToStart,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Generated topics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: (outputsAsync.valueOrNull == null) ? null : onNextToResults,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: topicsAsync.when(
              data: (topics) {
                if (topics.isEmpty) {
                  return const Center(
                      child: Text('No topics yet. Go back and generate.'));
                }

                final selected = (selectedId == null)
                    ? null
                    : topics.firstWhere(
                        (t) => t.id == selectedId,
                        orElse: () => topics.first,
                      );

                return LayoutBuilder(
                  builder: (context, c) {
                    final wide = c.maxWidth >= 900;

                    final list = _TopicList(
                      topics: topics,
                      selectedId: selectedId,
                      onSelect: (t) {
                        ref.read(selectedTopicIdProvider.notifier).state = t.id;
                        ref.read(editableTopicProvider.notifier).state = t;
                      },
                    );

                    final editor = _TopicEditor(
                      topic: editable ?? selected ?? topics.first,
                      onChanged: (t) =>
                          ref.read(editableTopicProvider.notifier).state = t,
                      onGenerateOutputs: () async {
                        await ref.read(outputsProvider.notifier).generate();
                        if (context.mounted) onNextToResults();
                      },
                    );

                    if (!wide) {
                      return ListView(
                        children: [
                          list,
                          const SizedBox(height: 12),
                          editor,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 4, child: list),
                        const SizedBox(width: 12),
                        Expanded(flex: 5, child: editor),
                      ],
                    );
                  },
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

class _TopicList extends StatelessWidget {
  final List<Topic> topics;
  final String? selectedId;
  final ValueChanged<Topic> onSelect;

  const _TopicList({
    required this.topics,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: topics.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final t = topics[i];
          final selected = t.id == selectedId;
          return ListTile(
            title: Text(t.title),
            subtitle: Text(t.angle, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: selected ? const Icon(Icons.check_circle) : const Icon(Icons.chevron_right),
            onTap: () => onSelect(t),
          );
        },
      ),
    );
  }
}

class _TopicEditor extends StatelessWidget {
  final Topic topic;
  final ValueChanged<Topic> onChanged;
  final VoidCallback onGenerateOutputs;

  const _TopicEditor({
    required this.topic,
    required this.onChanged,
    required this.onGenerateOutputs,
  });

  @override
  Widget build(BuildContext context) {
    final hookCtrl = TextEditingController(text: topic.hook);
    final angleCtrl = TextEditingController(text: topic.angle);
    final keyPointsCtrl = TextEditingController(text: topic.keyPoints.join('\n'));

    void apply() {
      final next = topic.copyWith(
        hook: hookCtrl.text.trim(),
        angle: angleCtrl.text.trim(),
        keyPoints: keyPointsCtrl.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );
      onChanged(next);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detailed (editable)',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Title: ${topic.title}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: hookCtrl,
              decoration: const InputDecoration(
                  labelText: 'Hook', border: OutlineInputBorder()),
              onChanged: (_) => apply(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: angleCtrl,
              decoration: const InputDecoration(
                  labelText: 'Angle', border: OutlineInputBorder()),
              onChanged: (_) => apply(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: keyPointsCtrl,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Key points (1 per line)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => apply(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                apply();
                onGenerateOutputs();
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate for YouTube / TikTok / Telegram'),
            ),
          ],
        ),
      ),
    );
  }
}
