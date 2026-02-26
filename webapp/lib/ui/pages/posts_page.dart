import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models.dart';
import '../../core/state.dart';

class PostsPage extends ConsumerWidget {
  final VoidCallback onBackToStory;
  const PostsPage({super.key, required this.onBackToStory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    final topic = ref.watch(editableTopicProvider);
    final story = ref.watch(storyProvider).value;
    final promptText = ref.watch(promptTextProvider);
    final attachmentCount = ref.watch(promptAttachmentsProvider).length;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to story',
                onPressed: onBackToStory,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Generated posts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              TextButton.icon(
                onPressed: postsAsync.isLoading
                    ? null
                    : () async {
                        await ref.read(postsProvider.notifier).generate();
                      },
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: postsAsync.when(
              data: (out) {
                if (out == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('No posts yet.',
                              style: TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text('Go back and generate story, then posts.'),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: (topic == null || story == null)
                                ? null
                                : () async {
                                    await ref.read(postsProvider.notifier).generate();
                                  },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Generate posts'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Save to history once posts exist
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final id = 'h_${DateTime.now().millisecondsSinceEpoch}';
                  final item = HistoryItem(
                    id: id,
                    createdAt: DateTime.now(),
                    promptText: promptText,
                    attachmentCount: attachmentCount,
                    selectedTopicTitle: topic?.title ?? '',
                    story: story,
                    platform_stories: out,
                  );
                  await ref.read(historyProvider.notifier).add(item);
                });

                return ListView(
                  children: [
                    _OutputCard(title: 'YouTube', text: out.yt_story.description),
                    const SizedBox(height: 12),
                    _OutputCard(title: 'TikTok', text: out.tiktok_story.description),
                    const SizedBox(height: 12),
                    _OutputCard(title: 'Instagram', text: out.insta_story.description),
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
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
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
