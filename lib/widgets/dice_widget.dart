import 'dart:math';
import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int value;
  final VoidCallback onRoll;
  final Color color;
  final bool enabled;

  const DiceWidget({
    super.key,
    required this.value,
    required this.onRoll,
    required this.color,
    this.enabled = true,
  });

  @override
  State<DiceWidget> createState() => DiceWidgetState();
}

class DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    triggerRoll();
  }

  void triggerRoll() {
    _controller.forward(from: 0).then((_) {
      widget.onRoll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Add a rotation and scale effect during animation
          final angle = _controller.value * 2 * pi;
          final scale = 1.0 - (_controller.value * 0.2); // slight shrink
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(angle)
              ..scale(scale),
            child: _buildDiceFace(widget.enabled ? widget.value : 0),
          );
        },
      ),
    );
  }

  Widget _buildDiceFace(int val) {
    // If value is 0 or animation is happening, show a question mark or blank
    if (_controller.isAnimating) {
      val = Random().nextInt(6) + 1; // Show random faces while rolling
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: widget.enabled ? widget.color : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: Center(
        child: Text(
          val == 0 ? '?' : '$val',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
