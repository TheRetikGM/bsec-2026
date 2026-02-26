import 'package:flutter/material.dart';

class PlatformOption {
  final String id;
  final String label;
  final IconData icon;

  const PlatformOption(this.id, this.label, this.icon);
}

const platformOptions = <PlatformOption>[
  PlatformOption('youtube', 'YouTube', Icons.ondemand_video),
  PlatformOption('instagram', 'Instagram', Icons.photo_camera),
  PlatformOption('tiktok', 'TikTok', Icons.movie_creation_outlined),
  PlatformOption('email', 'Email', Icons.email_outlined),
];

Future<Set<String>?> showPlatformSelectorDialog(
  BuildContext context, {
  required Set<String> initialSelection,
  String title = 'Generate for platforms',
  String confirmLabel = 'Generate',
}) {
  final selected = <String>{...initialSelection};

  return showDialog<Set<String>>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final opt in platformOptions)
                    CheckboxListTile(
                      value: selected.contains(opt.id),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: Icon(opt.icon),
                      title: Text(opt.label),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            selected.add(opt.id);
                          } else {
                            selected.remove(opt.id);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: selected.isEmpty ? null : () => Navigator.pop(ctx, selected),
                child: Text(confirmLabel),
              ),
            ],
          );
        },
      );
    },
  );
}
