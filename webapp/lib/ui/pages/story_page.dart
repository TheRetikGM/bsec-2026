import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';
import '../widgets/animated_dots_text.dart';
import '../widgets/platform_selector.dart';

class StoryPage extends ConsumerWidget {
  final VoidCallback onBackToTopics;
  final VoidCallback onNextToPosts;

  const StoryPage({
    super.key,
    required this.onBackToTopics,
    required this.onNextToPosts,
  });

  String _platformLabel(Set<String> selected) {
    final labels = platformOptions
        .where((o) => selected.contains(o.id))
        .map((o) => o.label)
        .toList(growable: false);
    if (labels.isEmpty) return 'None selected';
    return labels.join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(editableTopicProvider);
    final storyAsync = ref.watch(storyProvider);
    final story = storyAsync.value;
    final postsAsync = ref.watch(postsProvider);
    final selectedPlatforms = ref.watch(selectedPlatformsProvider);
    final idx = ref.watch(selectedTopicIdProvider);

    Widget kv(String key, String value) {
      final base = DefaultTextStyle.of(context).style;
      final keyColor = (base.color ?? Colors.black).withOpacity(0.65);
      return RichText(
        text: TextSpan(
          style: base,
          children: [
            TextSpan(
              text: '$key: ',
              style: TextStyle(color: keyColor, fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      );
    }

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
                child: Text(
                  'Story overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: (story == null) ? null : onNextToPosts,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Generate platform outputs (moved to top).
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Platforms',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _platformLabel(selectedPlatforms),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: (story == null || postsAsync.isLoading)
                        ? null
                        : () async {
                            await ref.read(postsProvider.notifier).generate();
                            onNextToPosts();
                          },
                    icon: const Icon(Icons.auto_fix_high),
                    label: postsAsync.isLoading
                        ? const AnimatedDotsText('Generating')
                        : const Text('Generate for platforms'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          if (idx == null || profile == null)
            const Expanded(
              child: Center(child: Text('No topic selected. Go back and choose a topic.')),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.topic,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          kv('Goal', profile.goal),
                          const SizedBox(height: 6),
                          kv('Target group', profile.target_group),
                          const SizedBox(height: 6),
                          kv('Main thought', profile.main_thought),
                          const SizedBox(height: 6),
                          kv('Tone', profile.tone),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: storyAsync.isLoading
                                ? null
                                : () async {
                                    await ref.read(storyProvider.notifier).generate();
                                  },
                            icon: const Icon(Icons.auto_awesome),
                            label: storyAsync.isLoading
                                ? const AnimatedDotsText('Generating')
                                : const Text('Generate story overview'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  storyAsync.when(
                    data: (s) {
                      if (s == null) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('No story yet. Generate above.'),
                          ),
                        );
                      }
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Generated story',
                                      style: TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Copy',
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(
                                          text: ref.read(storyProvider).value!.story));
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
                              SelectableText(s.story),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('Error: $e'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
