import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state.dart';
import 'panels/history_panel.dart';
import 'panels/topics_panel.dart';
import 'pages/start_page.dart';
import 'pages/topics_page.dart';
import 'pages/results_page.dart';

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
    ref.read(pageIndexProvider.notifier).state = index;
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
          onPageChanged: (i) => ref.read(pageIndexProvider.notifier).state = i,
          children: [
            StartPage(onNavigateToTopics: () => _goTo(1)),
            TopicsPage(
              onBackToStart: () => _goTo(0),
              onNextToResults: () => _goTo(2),
            ),
            ResultsPage(onBackToTopics: () => _goTo(1)),
          ],
        );

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                const SizedBox(width: 340, child: HistoryPanel()),
                const VerticalDivider(width: 1),
                Expanded(child: center),
                const VerticalDivider(width: 1),
                const SizedBox(width: 340, child: TopicsPanel()),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Redakcia'),
          ),
          drawer: const Drawer(child: SafeArea(child: HistoryPanel())),
          endDrawer: const Drawer(child: SafeArea(child: TopicsPanel())),
          body: center,
        );
      },
    );
  }
}
