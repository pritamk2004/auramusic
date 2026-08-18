import 'dart:math';
import 'package:flutter/material.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final int barCount;
  final double height;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.color = const Color(0xFF1DB954),
    this.barCount = 18,
    this.height = 40.0,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<double> _targetHeights = [];
  final List<double> _currentHeights = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.barCount; i++) {
      _targetHeights.add(0.2 + _random.nextDouble() * 0.8);
      _currentHeights.add(0.2);
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..addListener(() {
        if (widget.isPlaying) {
          setState(() {
            for (int i = 0; i < widget.barCount; i++) {
              if ((_currentHeights[i] - _targetHeights[i]).abs() < 0.1) {
                _targetHeights[i] = 0.15 + _random.nextDouble() * 0.85;
              }
              _currentHeights[i] += (_targetHeights[i] - _currentHeights[i]) * 0.3;
            }
          });
        }
      });

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
      setState(() {
        for (int i = 0; i < widget.barCount; i++) {
          _currentHeights[i] = 0.15;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (i) {
          final h = (_currentHeights[i] * widget.height).clamp(4.0, widget.height);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            width: 3.5,
            height: h,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.85),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
