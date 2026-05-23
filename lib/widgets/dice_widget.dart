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
      duration: const Duration(milliseconds: 600),
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
          // Bouncy 3D rotation effect
          final progress = _controller.value;
          final angleX = _controller.isAnimating ? progress * pi * 4 : 0.4;
          final angleY = _controller.isAnimating ? progress * pi * 2 : -0.4;
          
          // Bouncy scale: start at 1, go up to 1.3, back to 1
          final scale = 1.0 + sin(progress * pi) * 0.3;
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // perspective
              ..rotateX(angleX)
              ..rotateY(angleY)
              ..rotateZ(progress * pi)
              ..scale(scale),
            child: _buildDiceFace(widget.enabled ? widget.value : 0),
          );
        },
      ),
    );
  }

  Widget _buildDiceFace(int val) {
    if (_controller.isAnimating) {
      val = Random().nextInt(6) + 1;
    }

    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.enabled ? widget.color.withOpacity(0.8) : Colors.grey.shade400,
            widget.enabled ? widget.color : Colors.grey.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
        boxShadow: [
          BoxShadow(
            color: widget.enabled ? widget.color.withOpacity(0.5) : Colors.black26,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Colors.white30,
            blurRadius: 2,
            offset: Offset(-2, -2),
          ),
        ],
      ),
      child: _buildDots(val == 0 ? 6 : val),
    );
  }

  Widget _buildDots(int val) {
    List<Widget> dots = [];
    final dotColor = Colors.white;
    
    Widget dot() => Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))
        ],
      ),
    );

    // Positions based on a 3x3 grid
    bool tl = val > 1; // top left
    bool tr = val > 3; // top right
    bool ml = val == 6; // mid left
    bool mr = val == 6; // mid right
    bool bl = val > 3; // bottom left
    bool br = val > 1; // bottom right
    bool cc = val % 2 == 1; // center

    return Stack(
      children: [
        if (tl) Positioned(top: 4, left: 4, child: dot()),
        if (tr) Positioned(top: 4, right: 4, child: dot()),
        if (ml) Positioned(top: 24, left: 4, child: dot()),
        if (cc) Positioned(top: 24, left: 24, child: dot()),
        if (mr) Positioned(top: 24, right: 4, child: dot()),
        if (bl) Positioned(bottom: 4, left: 4, child: dot()),
        if (br) Positioned(bottom: 4, right: 4, child: dot()),
      ],
    );
  }
}
