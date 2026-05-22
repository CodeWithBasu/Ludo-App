import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 2,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CustomPaint(
            painter: BoardPainter(),
          ),
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final Color redBase = const Color(0xFFD32F2F);
  final Color greenBase = const Color(0xFF388E3C);
  final Color yellowBase = const Color(0xFFFBC02D);
  final Color blueBase = const Color(0xFF1976D2);
  final Color emptyCell = const Color(0xFFF0F2F5);

  void _drawGlossyRect(Canvas canvas, Rect rect, Color color, {bool isBase = false}) {
    // Drop shadow (inner or outer depending on style, here just simple background)
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(isBase ? 20 : 6));

    // Base Gradient
    final Paint gradientPaint = Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomRight,
        [color.withOpacity(0.8), color],
      );
    canvas.drawRRect(rrect, gradientPaint);

    // Inner glossy highlight
    final Paint highlight = Paint()
      ..shader = ui.Gradient.linear(
        rect.topLeft,
        rect.bottomRight,
        [Colors.white.withOpacity(0.6), Colors.transparent],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, highlight);
  }

  @override
  void paint(Canvas canvas, Size size) {
    double cellSize = size.width / 15;

    // Draw grid background (empty cells)
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        _drawGlossyRect(
          canvas,
          Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize).deflate(1.5),
          emptyCell,
        );
      }
    }

    // Draw Bases
    _drawBase(canvas, 0, 0, cellSize, redBase);
    _drawBase(canvas, 9 * cellSize, 0, cellSize, greenBase);
    _drawBase(canvas, 0, 9 * cellSize, cellSize, blueBase);
    _drawBase(canvas, 9 * cellSize, 9 * cellSize, cellSize, yellowBase);

    // Draw Home
    _drawHome(canvas, 6 * cellSize, 6 * cellSize, cellSize * 3);

    // Draw colored paths
    _drawVerticalPath(canvas, 6 * cellSize, 0, cellSize, greenBase); // Top
    _drawVerticalPath(canvas, 6 * cellSize, 9 * cellSize, cellSize, blueBase); // Bottom
    _drawHorizontalPath(canvas, 0, 6 * cellSize, cellSize, redBase); // Left
    _drawHorizontalPath(canvas, 9 * cellSize, 6 * cellSize, cellSize, yellowBase); // Right
  }

  void _drawBase(Canvas canvas, double dx, double dy, double cellSize, Color color) {
    Rect baseRect = Rect.fromLTWH(dx, dy, cellSize * 6, cellSize * 6).deflate(2);
    _drawGlossyRect(canvas, baseRect, color, isBase: true);

    // Inner white container
    Rect innerRect = Rect.fromLTWH(dx + cellSize, dy + cellSize, cellSize * 4, cellSize * 4).deflate(2);
    _drawGlossyRect(canvas, innerRect, Colors.white, isBase: true);

    // 4 spawn spots
    _drawSpawnCircle(canvas, dx + cellSize * 1.5, dy + cellSize * 1.5, cellSize, color);
    _drawSpawnCircle(canvas, dx + cellSize * 3.5, dy + cellSize * 1.5, cellSize, color);
    _drawSpawnCircle(canvas, dx + cellSize * 1.5, dy + cellSize * 3.5, cellSize, color);
    _drawSpawnCircle(canvas, dx + cellSize * 3.5, dy + cellSize * 3.5, cellSize, color);
  }

  void _drawSpawnCircle(Canvas canvas, double cx, double cy, double cellSize, Color color) {
    Rect rect = Rect.fromLTWH(cx, cy, cellSize, cellSize).deflate(2);
    
    // Inset shadow look for spawn points
    canvas.drawOval(rect, Paint()..color = Colors.grey.shade300);
    
    // Draw the colored center
    Rect inner = rect.deflate(cellSize * 0.15);
    canvas.drawOval(
      inner,
      Paint()
        ..shader = ui.Gradient.radial(
          inner.center,
          inner.width / 2,
          [color.withOpacity(0.5), color],
        ),
    );
  }

  void _drawHome(Canvas canvas, double dx, double dy, double size) {
    Path path = Path();
    
    // Top (Green)
    path.moveTo(dx, dy);
    path.lineTo(dx + size, dy);
    path.lineTo(dx + size / 2, dy + size / 2);
    path.close();
    canvas.drawPath(path, Paint()..shader = ui.Gradient.linear(Offset(dx, dy), Offset(dx + size/2, dy + size/2), [greenBase, Colors.green.shade900]));

    // Right (Yellow)
    path = Path();
    path.moveTo(dx + size, dy);
    path.lineTo(dx + size, dy + size);
    path.lineTo(dx + size / 2, dy + size / 2);
    path.close();
    canvas.drawPath(path, Paint()..shader = ui.Gradient.linear(Offset(dx+size, dy), Offset(dx + size/2, dy + size/2), [yellowBase, Colors.amber.shade900]));

    // Bottom (Blue)
    path = Path();
    path.moveTo(dx, dy + size);
    path.lineTo(dx + size, dy + size);
    path.lineTo(dx + size / 2, dy + size / 2);
    path.close();
    canvas.drawPath(path, Paint()..shader = ui.Gradient.linear(Offset(dx, dy+size), Offset(dx + size/2, dy + size/2), [blueBase, Colors.blue.shade900]));

    // Left (Red)
    path = Path();
    path.moveTo(dx, dy);
    path.lineTo(dx, dy + size);
    path.lineTo(dx + size / 2, dy + size / 2);
    path.close();
    canvas.drawPath(path, Paint()..shader = ui.Gradient.linear(Offset(dx, dy), Offset(dx + size/2, dy + size/2), [redBase, Colors.red.shade900]));
  }

  void _drawVerticalPath(Canvas canvas, double dx, double dy, double cellSize, Color color) {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 3; j++) {
        Rect rect = Rect.fromLTWH(dx + j * cellSize, dy + i * cellSize, cellSize, cellSize).deflate(1.5);
        if (j == 1 && i != 0 && i != 5) {
          _drawGlossyRect(canvas, rect, color);
        } else if ((color == greenBase && j == 2 && i == 1) || (color == blueBase && j == 0 && i == 4)) {
          _drawGlossyRect(canvas, rect, color);
        }
      }
    }
  }

  void _drawHorizontalPath(Canvas canvas, double dx, double dy, double cellSize, Color color) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 6; j++) {
        Rect rect = Rect.fromLTWH(dx + j * cellSize, dy + i * cellSize, cellSize, cellSize).deflate(1.5);
        if (i == 1 && j != 0 && j != 5) {
          _drawGlossyRect(canvas, rect, color);
        } else if ((color == redBase && i == 0 && j == 1) || (color == yellowBase && i == 2 && j == 4)) {
          _drawGlossyRect(canvas, rect, color);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
