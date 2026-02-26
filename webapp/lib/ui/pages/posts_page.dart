import 'dart:math';

import 'package:ai_redakcia_frontend/models/history_models/history_model.dart';
import 'package:ai_redakcia_frontend/models/story_models/insta_story_model.dart';
import 'package:ai_redakcia_frontend/models/story_models/tiktok_story_model.dart';
import 'package:ai_redakcia_frontend/models/story_models/youtube_story_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';
import '../widgets/animated_dots_text.dart';

class PostsPage extends ConsumerWidget {
  final VoidCallback onBackToStory;
  const PostsPage({super.key, required this.onBackToStory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsProvider);
    final selectedPlatforms = ref.watch(selectedPlatformsProvider);
    final profile = ref.watch(editableTopicProvider);
    final story = ref.watch(storyProvider).value;
    final promptText = ref.watch(promptTextProvider);

    Future<void> regenerate({Set<String>? picked}) async {
      await ref.read(postsProvider.notifier).generate();
    }

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
                child: Text(
                  'Generated posts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: postsAsync.isLoading ? null : () => regenerate(),
                icon: const Icon(Icons.refresh),
                label: postsAsync.isLoading
                    ? const AnimatedDotsText('Generating')
                    : const Text('Regenerate'),
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
                          const Text('Go back and generate story, then platform outputs.'),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: (profile == null || story == null || postsAsync.isLoading)
                                ? null
                                : () async {
                                    await regenerate();
                                  },
                            icon: const Icon(Icons.auto_fix_high),
                            label: postsAsync.isLoading
                                ? const AnimatedDotsText('Generating')
                                : const Text('Generate for platforms'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  // Persist generated outputs in local history (used for later imports/analysis).
                  // Note: HistoryModel currently stores YT/IG/TikTok only.
                  if (profile == null || story == null) return;

                  final id = Random(32).nextInt(0x7FFFFFFFFFFFFFFF);
                  final item = HistoryModel(
                    id: id,
                    date: DateTime.now(),
                    promptText: promptText,
                    topic: profile.topic,
                    story: story,
                    yt_model: out.yt_story.toHistory(),
                    tiktokmodel: out.tiktok_story.toHistory(),
                    insta_model: out.insta_story.toHistory(),
                  );
                  await ref.read(historyProvider.notifier).add(item);
                });

                final ytText = out.yt_story.description;
                final ttText = out.tiktok_story.description;
                final igText = out.insta_story.description;

                final cards = <Widget>[];
                void addCard(String title, String text) {
                  if (cards.isNotEmpty) cards.add(const SizedBox(height: 12));
                  cards.add(_OutputCard(title: title, text: text));
                }

                if (selectedPlatforms.contains('youtube')) addCard('YouTube', ytText);
                if (selectedPlatforms.contains('tiktok')) addCard('TikTok', ttText);
                if (selectedPlatforms.contains('instagram')) addCard('Instagram', igText);

                if (cards.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'No platforms selected.',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          const Text('Select at least one platform to display outputs.'),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: postsAsync.isLoading ? null : () => regenerate(),
                            icon: const Icon(Icons.tune),
                            label: const Text('Select platforms'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView(children: cards);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
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
              maxLines: 20,
              readOnly: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
}
