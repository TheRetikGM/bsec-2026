import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';

class StartPage extends ConsumerWidget {
  final VoidCallback onNavigateToTopics;
  const StartPage({super.key, required this.onNavigateToTopics});

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
    final promptText = ref.watch(promptTextProvider);
    final attachments = ref.watch(promptAttachmentsProvider);
    final topicsAsync = ref.watch(topicsProvider);

    final promptCtrl = TextEditingController(text: promptText)
      ..selection = TextSelection.collapsed(offset: promptText.length);

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: const [
            FlutterLogo(size: 44),
            SizedBox(width: 12),
            Expanded(
              child: Text('Multi-Agent Content Studio',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Prompt (text + images). Paste from clipboard.',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: promptCtrl,
          minLines: 5,
          maxLines: 10,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Describe your idea… (or leave empty to “Try it yourself”)',
          ),
          onChanged: (v) => ref.read(promptTextProvider.notifier).set(v),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final res = await readClipboardTextAndImages();
                final current = ref.read(promptTextProvider);

                if (res.text != null && res.text!.trim().isNotEmpty) {
                  ref.read(promptTextProvider.notifier).set(
                      (current.trim().isEmpty) ? res.text!.trim() : '$current\n${res.text!.trim()}');
                }
                for (final img in res.images) {
                  ref.read(promptAttachmentsProvider.notifier).addBytes(img);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pasted: text=${res.text != null}, images=${res.images.length}')),
                  );
                }
              },
              icon: const Icon(Icons.paste),
              label: const Text('Paste'),
            ),
            OutlinedButton.icon(
              onPressed: attachments.isEmpty ? null : () => ref.read(promptAttachmentsProvider.notifier).clear(),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear images'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (attachments.isNotEmpty) ...[
          const Text('Attached images', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final a = attachments[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(a.bytes, width: 92, height: 92, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close),
                        onPressed: () => ref.read(promptAttachmentsProvider.notifier).remove(a.id),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        Center(
          child: _CircleGenerateButton(
            isBusy: topicsAsync.isLoading,
            label: (promptText.trim().isEmpty && attachments.isEmpty) ? 'Try it\nYourself' : 'Generate\nTopics',
            onPressed: () async {
              // Reset downstream selections
              ref.read(selectedTopicIdProvider.notifier).set(null);
              ref.read(expandedTopicIdProvider.notifier).close();
              ref.read(editableTopicProvider.notifier).set(null);
              ref.read(storyProvider.notifier).clear();
              ref.read(postsProvider.notifier).clear();

              await ref.read(topicsProvider.notifier).generateFromPrompt();
              onNavigateToTopics();
            },
          ),
        ),
        const SizedBox(height: 16),
        const Text('Trending (tap to use)', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trending
              .map((t) => ActionChip(
                    label: Text(t),
                    onPressed: () => ref.read(promptTextProvider.notifier).set(t),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _CircleGenerateButton extends StatelessWidget {
  final bool isBusy;
  final String label;
  final VoidCallback onPressed;

  const _CircleGenerateButton({
    required this.isBusy,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: isBusy ? null : onPressed,
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.primary,
          boxShadow: const [
            BoxShadow(blurRadius: 18, spreadRadius: 1, offset: Offset(0, 8), color: Colors.black26),
          ],
        ),
        child: Center(
          child: isBusy
              ? const SizedBox(
                  width: 42,
                  height: 42,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                ),
        ),
      ),
    );
  }
}
