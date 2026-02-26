import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state.dart';
import 'panels/history_panel.dart';
import 'panels/next_panel.dart';
import 'pages/start_page.dart';
import 'pages/topics_page.dart';
import 'pages/story_page.dart';
import 'pages/posts_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    ref.read(pageIndexProvider.notifier).set(index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(pageIndexProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients && _controller.page?.round() != pageIndex) {
        _controller.jumpToPage(pageIndex);
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1200;

        final center = PageView(
          controller: _controller,
          onPageChanged: (i) => ref.read(pageIndexProvider.notifier).set(i),
          children: [
            StartPage(onNavigateToTopics: () => _goTo(1)),
            TopicsPage(
              onBackToStart: () => _goTo(0),
              onNextToStory: () => _goTo(2),
            ),
            StoryPage(
              onBackToTopics: () => _goTo(1),
              onNextToPosts: () => _goTo(3),
            ),
            PostsPage(onBackToStory: () => _goTo(2)),
          ],
        );

        if (wide) {
          final showRight = pageIndex != 3;
          return Scaffold(
            body: Row(
              children: [
                const SizedBox(width: 340, child: HistoryPanel()),
                const VerticalDivider(width: 1),
                Expanded(child: center),
                if (showRight) ...[
                  const VerticalDivider(width: 1),
                  SizedBox(
                    width: 340,
                    child: NextPanel(
                      currentPageIndex: pageIndex,
                      onGoNext: () => _goTo(pageIndex + 1),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        // Narrow layout: use AppBar buttons for nav + drawers for panels.
        final hasNext = pageIndex != 3;
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Redakcia'),
            actions: [
              if (hasNext)
                IconButton(
                  tooltip: 'Next',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _goTo(pageIndex + 1),
                ),
            ],
          ),
          drawer: const Drawer(child: SafeArea(child: HistoryPanel())),
          endDrawer: hasNext
              ? Drawer(
                  child: SafeArea(
                    child: NextPanel(
                      currentPageIndex: pageIndex,
                      onGoNext: () => _goTo(pageIndex + 1),
                    ),
                  ),
                )
              : null,
          body: center,
        );
      },
    );
  }
}
