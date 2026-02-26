import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';

class StoryPage extends ConsumerWidget {
  final VoidCallback onBackToTopics;
  final VoidCallback onNextToPosts;

  const StoryPage({
    super.key,
    required this.onBackToTopics,
    required this.onNextToPosts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(editableTopicProvider);
    final storyAsync = ref.watch(storyProvider);
    final idx = ref.watch(selectedTopicIdProvider);

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
                child: Text('Story overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              TextButton.icon(
                onPressed: (storyAsync.value == null) ? null : onNextToPosts,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
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
                          Text(profile.topic,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('Goal: ${profile.goal}'),
                          const SizedBox(height: 6),
                          Text('Target group: ${profile.target_group}'),
                          const SizedBox(height: 6),
                          Text('Main thought: ${profile.main_thought}'),
                          const SizedBox(height: 6),
                          Text('Tone: ${profile.tone}'),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: storyAsync.isLoading
                                ? null
                                : () async {
                                    await ref.read(storyProvider.notifier).generate();
                                  },
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Generate story overview'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  storyAsync.when(
                    data: (story) {
                      if (story == null) {
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
                                    child: Text('Generated story',
                                        style: TextStyle(fontWeight: FontWeight.w800)),
                                  ),
                                  IconButton(
                                    tooltip: 'Copy',
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(text: story.story));
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
                              SelectableText(story.story),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () async {
                                  await ref.read(postsProvider.notifier).generate();
                                  onNextToPosts();
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Generate posts'),
                              ),
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
