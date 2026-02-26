import 'dart:async';

import 'package:flutter/material.dart';

/// Lightweight animated text like: "Generating.", "Generating..", "Generating..."
class AnimatedDotsText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration period;
  final int maxDots;

  const AnimatedDotsText(
    this.text, {
    super.key,
    this.style,
    this.period = const Duration(milliseconds: 350),
    this.maxDots = 3,
  });

  @override
  State<AnimatedDotsText> createState() => _AnimatedDotsTextState();
}

class _AnimatedDotsTextState extends State<AnimatedDotsText> {
  Timer? _t;
  int _dots = 0;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(widget.period, (_) {
      if (!mounted) return;
      setState(() {
        _dots = (_dots + 1) % (widget.maxDots + 1);
      });
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dots;
    return Text('${widget.text}$dots', style: widget.style);
  }
}
