import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state.dart';

class TopicsPage extends ConsumerWidget {
  final VoidCallback onBackToStart;
  final VoidCallback onNextToStory;

  const TopicsPage({
    super.key,
    required this.onBackToStart,
    required this.onNextToStory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final expandedId = ref.watch(expandedTopicIdProvider);
    final selectedId = ref.watch(selectedTopicIdProvider);
    final settings = ref.watch(settingsProvider);

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
                child: Text('Generated topics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              TextButton.icon(
                onPressed: (selectedId == null) ? null : onNextToStory,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _GlobalSettingsCard(
            settings: settings,
            onChanged: (s) => ref.read(settingsProvider.notifier).update(s),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: topicsAsync.when(
              data: (topics) {
                if (topics.isEmpty) {
                  return const Center(child: Text('No topics yet. Go back and generate.'));
                }

                return ListView.separated(
                  itemCount: topics.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final t = topics[i];
                    final isExpanded = expandedId == t.id;

                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(t.title),
                            subtitle: Text(t.angle, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isExpanded)
                                  IconButton(
                                    tooltip: 'Close',
                                    icon: const Icon(Icons.expand_less),
                                    onPressed: () => ref.read(expandedTopicIdProvider.notifier).close(),
                                  )
                                else
                                  IconButton(
                                    tooltip: 'Open details',
                                    icon: const Icon(Icons.expand_more),
                                    onPressed: () => ref.read(expandedTopicIdProvider.notifier).toggle(t.id),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // select + toggle dropdown (allows close by tapping again)
                              ref.read(selectedTopicIdProvider.notifier).set(t.id);
                              ref.read(editableTopicProvider.notifier).set(t);
                              ref.read(postsProvider.notifier).clear();
                              ref.read(storyProvider.notifier).clear();
                              ref.read(expandedTopicIdProvider.notifier).toggle(t.id);
                            },
                          ),
                          AnimatedCrossFade(
                            crossFadeState:
                                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 180),
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: TopicDetailsEditor(
                                key: ValueKey('details_${t.id}'),
                                initialTopic: ref.watch(editableTopicProvider) ?? t,
                                onChanged: (next) {
                                  ref.read(editableTopicProvider.notifier).set(next);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _GlobalSettingsCard extends StatelessWidget {
  final GlobalSettings settings;
  final ValueChanged<GlobalSettings> onChanged;

  const _GlobalSettingsCard({required this.settings, required this.onChanged});

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
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'sk', child: Text('Slovak')),
                      DropdownMenuItem(value: 'cs', child: Text('Czech')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => onChanged(settings.copyWith(language: v ?? settings.language)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: settings.length,
                    items: const [
                      DropdownMenuItem(value: 'short', child: Text('Short')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'long', child: Text('Long')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Length',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => onChanged(settings.copyWith(length: v ?? settings.length)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: settings.tone,
              decoration: const InputDecoration(
                labelText: 'Tone',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => onChanged(settings.copyWith(tone: v.trim().isEmpty ? settings.tone : v.trim())),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: settings.includeHashtags,
              onChanged: (v) => onChanged(settings.copyWith(includeHashtags: v)),
              title: const Text('Include hashtags'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: settings.includeEmojis,
              onChanged: (v) => onChanged(settings.copyWith(includeEmojis: v)),
              title: const Text('Include emojis'),
            ),
          ],
        ),
      ),
    );
  }
}

class TopicDetailsEditor extends StatefulWidget {
  final Topic initialTopic;
  final ValueChanged<Topic> onChanged;

  const TopicDetailsEditor({
    super.key,
    required this.initialTopic,
    required this.onChanged,
  });

  @override
  State<TopicDetailsEditor> createState() => _TopicDetailsEditorState();
}

class _TopicDetailsEditorState extends State<TopicDetailsEditor> {
  late Topic _topic;
  late TextEditingController _hook;
  late TextEditingController _angle;
  late TextEditingController _keyPoints;

  @override
  void initState() {
    super.initState();
    _syncFrom(widget.initialTopic);
  }

  @override
  void didUpdateWidget(covariant TopicDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTopic.id != widget.initialTopic.id) {
      _syncFrom(widget.initialTopic);
    }
  }

  void _syncFrom(Topic t) {
    _topic = t;
    _hook = TextEditingController(text: t.hook);
    _angle = TextEditingController(text: t.angle);
    _keyPoints = TextEditingController(text: t.keyPoints.join('\n'));
  }

  @override
  void dispose() {
    _hook.dispose();
    _angle.dispose();
    _keyPoints.dispose();
    super.dispose();
  }

  void _emit() {
    final next = _topic.copyWith(
      hook: _hook.text.trim(),
      angle: _angle.text.trim(),
      keyPoints: _keyPoints.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
    widget.onChanged(next);
    setState(() => _topic = next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Details', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        TextField(
          controller: _hook,
          decoration: const InputDecoration(labelText: 'Hook', border: OutlineInputBorder()),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _angle,
          decoration: const InputDecoration(labelText: 'Angle', border: OutlineInputBorder()),
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _keyPoints,
          minLines: 4,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Key points (1 per line)',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }
}
