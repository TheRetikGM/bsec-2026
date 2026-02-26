import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/history_models/history_model.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryModel item;
  const HistoryDetailPage({super.key, required this.item});

  String _fmtDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final ytText = 'Title: ${item.yt_model.title}\n\nDescription:\n${item.yt_model.description}\n\nScenario:\n${item.yt_model.scenario}';
    final ttText = 'Description:\n${item.tiktokmodel.description}\n\nScenario:\n${item.tiktokmodel.scenario}';
    final igText = 'Caption:\n${item.insta_model.description}\n\nPhoto description:\n${item.insta_model.photo_description}';

    return Scaffold(
      appBar: AppBar(
        title: Text(item.topic.isEmpty ? 'History detail' : item.topic),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(
            _fmtDate(item.date),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _OutputCard(title: 'YouTube', text: ytText),
          const SizedBox(height: 12),
          _OutputCard(title: 'TikTok', text: ttText),
          const SizedBox(height: 12),
          _OutputCard(title: 'Instagram', text: igText),
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
            maxLines: 20,
            readOnly: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ]),
      ),
    );
  }
}
