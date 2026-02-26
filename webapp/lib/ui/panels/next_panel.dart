import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';

class NextPanel extends ConsumerWidget {
  final int currentPageIndex;
  final VoidCallback onGoNext;

  const NextPanel({
    super.key,
    required this.currentPageIndex,
    required this.onGoNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = switch (currentPageIndex) {
      0 => 'Next: Topics',
      1 => 'Next: Story overview',
      2 => 'Next: Posts',
      _ => 'Next',
    };

    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onGoNext,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(child: _PreviewBody(currentPageIndex: currentPageIndex)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewBody extends ConsumerWidget {
  final int currentPageIndex;
  const _PreviewBody({required this.currentPageIndex});

  static const trending = <String>[
    'AI tools for creators (2026)',
    'Hook formulas that boost retention',
    'From one long video to 10 shorts',
    'Instagram reels growth strategy',
    'Editing checklist for short-form',
    'How to validate topics fast',
    'Avoiding “AI generic” content',
    'Storytelling structure for 30s videos',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (currentPageIndex == 0) {
      return ListView(
        children: trending
            .map((t) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.trending_up),
                  title: Text(t, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => ref.read(promptTextProvider.notifier).set(t),
                ))
            .toList(),
      );
    }

    if (currentPageIndex == 1) {
      final topics = ref.watch(topicsProvider).value ?? const [];
      final idx = ref.watch(selectedTopicIdProvider);
      if (idx == null || idx < 0 || idx >= topics.length) {
        return const Text('Select a topic to continue.');
      }

      final profile = ref.watch(editableTopicProvider) ?? topics[idx];
      final story = ref.watch(storyProvider).value;

      return ListView(
        children: [
          Text(profile.topic, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Goal: ${profile.goal}', maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('Target: ${profile.target_group}', maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('Tone: ${profile.tone}', maxLines: 2, overflow: TextOverflow.ellipsis),
          const Divider(),
          Text(story == null ? 'Story not generated yet.' : 'Story ready ✅',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            story == null ? 'Open story page or click generate on the selected topic.' : story.story,
            maxLines: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    if (currentPageIndex == 2) {
      final posts = ref.watch(postsProvider).value;
      if (posts == null) {
        return const Text('Posts not generated yet. Generate on the story page.');
      }
      return ListView(
        children: [
          const Text('YouTube', style: TextStyle(fontWeight: FontWeight.w700)),
          Text(posts.yt_story.description, maxLines: 6, overflow: TextOverflow.ellipsis),
          const Divider(),
          const Text('TikTok', style: TextStyle(fontWeight: FontWeight.w700)),
          Text(posts.tiktok_story.description, maxLines: 6, overflow: TextOverflow.ellipsis),
          const Divider(),
          const Text('Instagram', style: TextStyle(fontWeight: FontWeight.w700)),
          Text(posts.insta_story.description, maxLines: 6, overflow: TextOverflow.ellipsis),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
