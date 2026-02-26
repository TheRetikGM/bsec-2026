import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state.dart';
import '../../models/profile_model.dart';

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
    final expandedIndex = ref.watch(expandedTopicIdProvider);
    final selectedIndex = ref.watch(selectedTopicIdProvider);
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
                onPressed: (selectedIndex == null) ? null : onNextToStory,
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
                    final p = topics[i];
                    final isExpanded = expandedIndex == i;
                    final isSelected = selectedIndex == i;

                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(p.topic, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              '${p.goal} • ${p.target_group}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Generate story',
                                  icon: const Icon(Icons.auto_awesome),
                                  onPressed: () async {
                                    ref.read(selectedTopicIdProvider.notifier).set(i);
                                    ref.read(editableTopicProvider.notifier).set(p);
                                    ref.read(storyProvider.notifier).clear();
                                    ref.read(postsProvider.notifier).clear();

                                    await ref.read(storyProvider.notifier).generate();
                                    onNextToStory();
                                  },
                                ),
                                IconButton(
                                  tooltip: isExpanded ? 'Close details' : 'Open details',
                                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                                  onPressed: () => ref.read(expandedTopicIdProvider.notifier).toggle(i),
                                ),
                              ],
                            ),
                            selected: isSelected,
                            onTap: () {
                              ref.read(selectedTopicIdProvider.notifier).set(i);
                              ref.read(editableTopicProvider.notifier).set(p);
                              ref.read(storyProvider.notifier).clear();
                              ref.read(postsProvider.notifier).clear();
                              ref.read(expandedTopicIdProvider.notifier).toggle(i);
                            },
                          ),
                          AnimatedCrossFade(
                            crossFadeState:
                                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 180),
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              child: ProfileDetailsEditor(
                                key: ValueKey('details_$i'),
                                initialProfile: ref.watch(editableTopicProvider) ?? p,
                                onChanged: (next) => ref.read(editableTopicProvider.notifier).set(next),
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

class ProfileDetailsEditor extends StatefulWidget {
  final ProfileModel initialProfile;
  final ValueChanged<ProfileModel> onChanged;

  const ProfileDetailsEditor({
    super.key,
    required this.initialProfile,
    required this.onChanged,
  });

  @override
  State<ProfileDetailsEditor> createState() => _ProfileDetailsEditorState();
}

class _ProfileDetailsEditorState extends State<ProfileDetailsEditor> {
  late ProfileModel _p;

  late TextEditingController _theme;
  late TextEditingController _goal;
  late TextEditingController _target;
  late TextEditingController _mainThought;
  late TextEditingController _tone;
  late TextEditingController _idea;

  @override
  void initState() {
    super.initState();
    _sync(widget.initialProfile);
  }

  @override
  void didUpdateWidget(covariant ProfileDetailsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProfile != widget.initialProfile) {
      _sync(widget.initialProfile);
    }
  }

  void _sync(ProfileModel p) {
    _p = p;
    _theme = TextEditingController(text: p.topic);
    _goal = TextEditingController(text: p.goal);
    _target = TextEditingController(text: p.target_group);
    _mainThought = TextEditingController(text: p.main_thought);
    _tone = TextEditingController(text: p.tone);
    _idea = TextEditingController(text: p.idea);
    setState(() {});
  }

  @override
  void dispose() {
    _theme.dispose();
    _goal.dispose();
    _target.dispose();
    _mainThought.dispose();
    _tone.dispose();
    _idea.dispose();
    super.dispose();
  }

  void _emit() {
    final next = _p.copyWith(
      topic: _theme.text.trim(),
      goal: _goal.text.trim(),
      target_group: _target.text.trim(),
      main_thought: _mainThought.text.trim(),
      tone: _tone.text.trim(),
      idea: _idea.text.trim(),
    );
    _p = next;
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Details (ProfileModel)', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        _field('Theme', _theme),
        const SizedBox(height: 10),
        _field('Goal', _goal),
        const SizedBox(height: 10),
        _field('Target group', _target),
        const SizedBox(height: 10),
        _field('Main thought', _mainThought, minLines: 2),
        const SizedBox(height: 10),
        _field('Tone', _tone),
        const SizedBox(height: 10),
        _field('Idea', _idea, minLines: 3),
      ],
    );
  }

  Widget _field(String label, TextEditingController c, {int minLines = 1}) {
    return TextField(
      controller: c,
      minLines: minLines,
      maxLines: minLines + 2,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => _emit(),
    );
  }
}
