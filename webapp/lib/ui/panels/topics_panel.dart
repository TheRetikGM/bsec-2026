import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';

class TopicsPanel extends ConsumerWidget {
  const TopicsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final selectedId = ref.watch(selectedTopicIdProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          const Text(
            'Generated topics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          topicsAsync.when(
            data: (topics) {
              if (topics.isEmpty) {
                return const Text('Empty (first run).');
              }
              return Column(
                children: topics.map((t) {
                  final selected = t.id == selectedId;
                  return Card(
                    child: ListTile(
                      dense: true,
                      title: Text(
                        t.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: selected ? const Icon(Icons.check_circle) : null,
                      onTap: () {
                        ref.read(selectedTopicIdProvider.notifier).state = t.id;
                        ref.read(editableTopicProvider.notifier).state = t;
                      },
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              ref.read(topicsProvider.notifier).clear();
              ref.read(selectedTopicIdProvider.notifier).state = null;
              ref.read(editableTopicProvider.notifier).state = null;
            },
            icon: const Icon(Icons.clear),
            label: const Text('Clear topics'),
          )
        ],
      ),
    );
  }
}
