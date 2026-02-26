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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (currentPageIndex == 0) {
      final topicsAsync = ref.watch(topicsProvider);
      return topicsAsync.when(
        data: (topics) {
          if (topics.isEmpty) return const Text('No topics yet. Generate from the prompt.');
          return ListView(
            children: topics
                .take(10)
                .map((t) => ListTile(
                      dense: true,
                      title: Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      );
    }

    if (currentPageIndex == 1) {
      final topics = ref.watch(topicsProvider).value ?? const [];
      final selectedId = ref.watch(selectedTopicIdProvider);
      final selected = selectedId == null
          ? null
          : topics.where((t) => t.id == selectedId).cast<dynamic>().firstOrNull;

      if (selected == null) {
        return const Text('Select a topic to continue.');
      }

      final story = ref.watch(storyProvider).value;
      return ListView(
        children: [
          Text(selected.title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Hook: ${selected.hook}', maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text('Angle: ${selected.angle}', maxLines: 3, overflow: TextOverflow.ellipsis),
          const Divider(),
          Text(story == null ? 'Story not generated yet.' : 'Story ready ✅',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            story == null ? 'Click to open the story page and generate.' : story.overview,
            maxLines: 10,
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

extension _FirstOrNullExt<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
