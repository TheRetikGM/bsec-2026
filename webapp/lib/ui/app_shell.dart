import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state.dart';
import 'panels/history_panel.dart';
import 'panels/topics_panel.dart';
import 'pages/results_page.dart';
import 'pages/start_page.dart';
import 'pages/topics_page.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _lastIndex = 0;

  void _goTo(int index) {
    final current = ref.read(pageIndexProvider);
    _lastIndex = current;
    ref.read(pageIndexProvider.notifier).state = index.clamp(0, 2).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(pageIndexProvider);

    final bool forward = pageIndex >= _lastIndex;
    final Widget currentPage = switch (pageIndex) {
      0 => StartPage(onNavigateToTopics: () => _goTo(1)),
      1 => TopicsPage(onBackToStart: () => _goTo(0), onNextToResults: () => _goTo(2)),
      _ => ResultsPage(onBackToTopics: () => _goTo(1)),
    };

    final Widget? nextPeek = switch (pageIndex) {
      0 => TopicsPage(
          onBackToStart: () {},
          onNextToResults: () {},
          preview: true,
        ),
      1 => ResultsPage(
          onBackToTopics: () {},
          preview: true,
        ),
      _ => null,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1200;

        if (!wide) {
          // Narrow: keep drawers; center switches with slide animation.
          return Scaffold(
            appBar: AppBar(title: const Text('AI Redakcia')),
            drawer: const Drawer(child: SafeArea(child: HistoryPanel())),
            endDrawer: const Drawer(child: SafeArea(child: TopicsPanel())),
            body: _SlideSwitcher(
              direction: forward ? AxisDirection.left : AxisDirection.right,
              child: KeyedSubtree(
                key: ValueKey(pageIndex),
                child: currentPage,
              ),
            ),
          );
        }

        // Wide: left = history; center = current page; right = "next slide" peek.
        return Scaffold(
          body: Row(
            children: [
              const SizedBox(width: 340, child: HistoryPanel()),
              const VerticalDivider(width: 1),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _SlideSwitcher(
                        direction: forward ? AxisDirection.left : AxisDirection.right,
                        child: KeyedSubtree(
                          key: ValueKey(pageIndex),
                          child: currentPage,
                        ),
                      ),
                    ),
                    if (nextPeek != null) ...[
                      const VerticalDivider(width: 1),
                      SizedBox(
                        width: 340,
                        child: _NextSlidePeek(
                          title: 'Next',
                          onTap: () => _goTo(pageIndex + 1),
                          child: nextPeek,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NextSlidePeek extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget child;

  const _NextSlidePeek({
    required this.title,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            AbsorbPointer(
              child: Transform.scale(
                scale: 0.98,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: child,
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Click to open',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideSwitcher extends StatelessWidget {
  final AxisDirection direction;
  final Widget child;

  const _SlideSwitcher({required this.direction, required this.child});

  @override
  Widget build(BuildContext context) {
    final begin = switch (direction) {
      AxisDirection.left => const Offset(1, 0),
      AxisDirection.right => const Offset(-1, 0),
      AxisDirection.up => const Offset(0, 1),
      AxisDirection.down => const Offset(0, -1),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (widget, animation) {
        final slideIn = Tween<Offset>(begin: begin, end: Offset.zero).animate(animation);
        return ClipRect(
          child: SlideTransition(position: slideIn, child: widget),
        );
      },
      child: child,
    );
  }
}
