import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state.dart';

class TopicsPage extends ConsumerWidget {
  final VoidCallback onBackToStart;
  final VoidCallback onNextToResults;
  final bool preview;

  const TopicsPage({
    super.key,
    required this.onBackToStart,
    required this.onNextToResults,
    this.preview = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final selectedId = ref.watch(selectedTopicIdProvider);
    final editable = ref.watch(editableTopicProvider);
    final settings = ref.watch(globalSettingsProvider);
    final outputsAsync = ref.watch(outputsProvider);

    final header = Row(
      children: [
        if (!preview)
          IconButton(
            tooltip: 'Back',
            onPressed: onBackToStart,
            icon: const Icon(Icons.arrow_back),
          ),
        if (!preview) const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Generated topics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        if (!preview)
          TextButton.icon(
            onPressed: (outputsAsync.value == null) ? null : onNextToResults,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
      ],
    );

    return Padding(
      padding: EdgeInsets.all(preview ? 10 : 14),
      child: Column(
        children: [
          if (!preview) header,
          if (preview)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Topics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          const SizedBox(height: 10),
          if (!preview)
            _GlobalSettingsCard(
              settings: settings,
              onChanged: (s) => ref.read(globalSettingsProvider.notifier).state = s,
            ),
          if (!preview) const SizedBox(height: 10),
          Expanded(
            child: topicsAsync.when(
              data: (topics) {
                if (topics.isEmpty) {
                  return Center(
                    child: Text(preview ? 'No topics yet.' : 'No topics yet. Go back and generate.'),
                  );
                }

                // Ensure selection exists
                final effectiveSelectedId = selectedId ?? topics.first.id;
                if (selectedId == null && !preview) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(selectedTopicIdProvider.notifier).state = topics.first.id;
                    ref.read(editableTopicProvider.notifier).state = topics.first;
                  });
                }

                final effectiveEditable =
                    (editable != null && editable.id == effectiveSelectedId)
                        ? editable
                        : topics.firstWhere((t) => t.id == effectiveSelectedId, orElse: () => topics.first);

                return Card(
                  child: ListView.builder(
                    itemCount: topics.length,
                    itemBuilder: (context, i) {
                      final t = topics[i];
                      final isOpen = t.id == effectiveSelectedId;

                      return Column(
                        children: [
                          ListTile(
                            title: Text(t.title),
                            subtitle: Text(t.angle, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Icon(preview ? Icons.chevron_right : (isOpen ? Icons.expand_less : Icons.expand_more)),
                            onTap: preview
                                ? null
                                : () {
                                    ref.read(selectedTopicIdProvider.notifier).state = t.id;
                                    ref.read(editableTopicProvider.notifier).state = t;
                                  },
                          ),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 220),
                            crossFadeState: isOpen && !preview
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox.shrink(),
                            secondChild: (isOpen && !preview)
                                ? _TopicDropdownEditor(
                                    key: ValueKey('editor_${t.id}'),
                                    topic: effectiveEditable,
                                    onChanged: (next) => ref
                                        .read(editableTopicProvider.notifier)
                                        .state = next,
                                    onGenerateOutputs: () async {
                                      await ref
                                          .read(outputsProvider.notifier)
                                          .generate();
                                      if (context.mounted) onNextToResults();
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (i != topics.length - 1) const Divider(height: 1),
                        ],
                      );
                    },
                  ),
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

class _GlobalSettingsCard extends StatelessWidget {
  final GlobalSettings settings;
  final ValueChanged<GlobalSettings> onChanged;

  const _GlobalSettingsCard({
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Global settings', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: settings.language,
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'cs', child: Text('Czech')),
                      DropdownMenuItem(value: 'sk', child: Text('Slovak')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      onChanged(settings.copyWith(language: v));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: settings.tone,
                    decoration: const InputDecoration(
                      labelText: 'Tone',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'professional', child: Text('Professional')),
                      DropdownMenuItem(value: 'casual', child: Text('Casual')),
                      DropdownMenuItem(value: 'funny', child: Text('Funny')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      onChanged(settings.copyWith(tone: v));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: settings.length,
                    decoration: const InputDecoration(
                      labelText: 'Length',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'short', child: Text('Short')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'long', child: Text('Long')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      onChanged(settings.copyWith(length: v));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hashtags'),
                    value: settings.includeHashtags,
                    onChanged: (v) => onChanged(settings.copyWith(includeHashtags: v)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Emojis'),
                    value: settings.includeEmojis,
                    onChanged: (v) => onChanged(settings.copyWith(includeEmojis: v)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicDropdownEditor extends StatelessWidget {
  final Topic topic;
  final ValueChanged<Topic> onChanged;
  final VoidCallback onGenerateOutputs;

  const _TopicDropdownEditor({
    super.key,
    required this.topic,
    required this.onChanged,
    required this.onGenerateOutputs,
  });

  @override
  Widget build(BuildContext context) {
    // Use initialValue fields (keyed by topic id) so it resets when selection changes.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const Text('Detail', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          TextFormField(
            key: ValueKey('hook_${topic.id}'),
            initialValue: topic.hook,
            decoration: const InputDecoration(labelText: 'Hook', border: OutlineInputBorder()),
            onChanged: (v) => onChanged(topic.copyWith(hook: v)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: ValueKey('angle_${topic.id}'),
            initialValue: topic.angle,
            decoration: const InputDecoration(labelText: 'Angle', border: OutlineInputBorder()),
            onChanged: (v) => onChanged(topic.copyWith(angle: v)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: ValueKey('kp_${topic.id}'),
            initialValue: topic.keyPoints.join('\n'),
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Key points (1 per line)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              final kps = v
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              onChanged(topic.copyWith(keyPoints: kps));
            },
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onGenerateOutputs,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate outputs'),
          ),
        ],
      ),
    );
  }
}
