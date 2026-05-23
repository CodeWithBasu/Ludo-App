import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as dart_math;

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
  final Color redBase = const Color(0xFFE53935);
  final Color greenBase = const Color(0xFF43A047);
  final Color yellowBase = const Color(0xFFFFB300);
  final Color blueBase = const Color(0xFF1E88E5);
  final Color gridLineColor = Colors.grey.shade300;

  void _drawTile(Canvas canvas, Rect rect, {Color? color, bool isSafe = false, bool isColoredSafe = false, bool isArrow = false, IconData? icon, Color? iconColor}) {
    // Draw base tile
    final Paint fillPaint = Paint()..color = color ?? Colors.white;
    canvas.drawRect(rect, fillPaint);
    
    // Draw thin grey border
    final Paint borderPaint = Paint()
      ..color = gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(rect, borderPaint);

    if (isSafe && !isColoredSafe) {
      _drawStar(canvas, rect, Colors.grey.shade400, false);
    } else if (isColoredSafe) {
      _drawStar(canvas, rect, Colors.white, true);
    } else if (isArrow) {
      _drawArrow(canvas, rect, fillPaint.color);
    }
  }

  void _drawStar(Canvas canvas, Rect rect, Color color, bool filled) {
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double r = rect.width * 0.35;
    
    Path path = Path();
    for (int i = 0; i < 5; i++) {
      double angle = -3.14159 / 2 + (i * 4 * 3.14159 / 5);
      double x = cx + r * dart_math.cos(angle);
      double y = cy + r * dart_math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final Paint paint = Paint()..color = color;
    if (filled) {
      paint.style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
      canvas.drawPath(path, Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1);
    } else {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.5;
      canvas.drawPath(path, paint);
    }
  }

  void _drawArrow(Canvas canvas, Rect rect, Color color) {
    // Arrow is drawn on the tile before the home path.
    // Actually, Ludo King arrows are solid colored triangles spanning the tile.
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final double size = rect.width * 0.6;
    
    Path path = Path();
    // We will just draw a generic arrow pointing towards the center based on tile position
    if (cx < rect.width * 5) { // Left (Red) - point Right
      path.moveTo(cx - size/2, cy - size/2);
      path.lineTo(cx + size/2, cy);
      path.lineTo(cx - size/2, cy + size/2);
    } else if (cx > rect.width * 10) { // Right (Yellow) - point Left
      path.moveTo(cx + size/2, cy - size/2);
      path.lineTo(cx - size/2, cy);
      path.lineTo(cx + size/2, cy + size/2);
    } else if (cy < rect.width * 5) { // Top (Green) - point Down
      path.moveTo(cx - size/2, cy - size/2);
      path.lineTo(cx, cy + size/2);
      path.lineTo(cx + size/2, cy - size/2);
    } else { // Bottom (Blue) - point Up
      path.moveTo(cx - size/2, cy + size/2);
      path.lineTo(cx, cy - size/2);
      path.lineTo(cx + size/2, cy + size/2);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  void paint(Canvas canvas, Size size) {
    double cellSize = size.width / 15;

    // 1. Draw Grid Paths
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        // Skip bases and center
        if ((i < 6 && j < 6) || (i < 6 && j > 8) || (i > 8 && j < 6) || (i > 8 && j > 8) || (i >= 6 && i <= 8 && j >= 6 && j <= 8)) {
          continue;
        }

        Rect rect = Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize);
        Color? tileColor;
        bool isColoredSafe = false;
        bool isSafe = false;
        bool isArrow = false;

        // Red Home Path
        if (i == 7 && j >= 1 && j <= 5) tileColor = redBase;
        // Green Home Path
        if (j == 7 && i >= 1 && i <= 5) tileColor = greenBase;
        // Yellow Home Path
        if (i == 7 && j >= 9 && j <= 13) tileColor = yellowBase;
        // Blue Home Path
        if (j == 7 && i >= 9 && i <= 13) tileColor = blueBase;

        // Start Tiles (Colored Safe)
        if (i == 6 && j == 1) { tileColor = redBase; isColoredSafe = true; }
        if (i == 1 && j == 8) { tileColor = greenBase; isColoredSafe = true; }
        if (i == 8 && j == 13) { tileColor = yellowBase; isColoredSafe = true; }
        if (i == 13 && j == 6) { tileColor = blueBase; isColoredSafe = true; }

        // White Safe Tiles
        if (i == 8 && j == 2) isSafe = true; // Red safe
        if (i == 2 && j == 6) isSafe = true; // Green safe
        if (i == 6 && j == 12) isSafe = true; // Yellow safe
        if (i == 12 && j == 8) isSafe = true; // Blue safe

        // Arrows
        if (i == 7 && j == 0) isArrow = true;
        if (i == 0 && j == 7) isArrow = true;
        if (i == 7 && j == 14) isArrow = true;
        if (i == 14 && j == 7) isArrow = true;
        
        Color arrowColor = Colors.white;
        if (isArrow) {
          if (j == 0) arrowColor = redBase;
          if (i == 0) arrowColor = greenBase;
          if (j == 14) arrowColor = yellowBase;
          if (i == 14) arrowColor = blueBase;
        }

        _drawTile(canvas, rect, color: tileColor, isSafe: isSafe, isColoredSafe: isColoredSafe, isArrow: isArrow);
        if (isArrow) {
          _drawArrow(canvas, rect, arrowColor);
        }
      }
    }

    // 2. Draw Center
    _drawCenter(canvas, 6 * cellSize, 6 * cellSize, cellSize * 3);

    // 3. Draw Corner Bases
    _drawBase(canvas, 0, 0, cellSize, redBase);
    _drawBase(canvas, 9 * cellSize, 0, cellSize, greenBase);
    _drawBase(canvas, 0, 9 * cellSize, cellSize, blueBase);
    _drawBase(canvas, 9 * cellSize, 9 * cellSize, cellSize, yellowBase);
  }

  void _drawCenter(Canvas canvas, double dx, double dy, double size) {
    Path path = Path();
    final Paint borderPaint = Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1;
    
    // Top (Green)
    path.moveTo(dx, dy); path.lineTo(dx + size, dy); path.lineTo(dx + size / 2, dy + size / 2); path.close();
    canvas.drawPath(path, Paint()..color = greenBase);
    canvas.drawPath(path, borderPaint);

    // Right (Yellow)
    path = Path(); path.moveTo(dx + size, dy); path.lineTo(dx + size, dy + size); path.lineTo(dx + size / 2, dy + size / 2); path.close();
    canvas.drawPath(path, Paint()..color = yellowBase);
    canvas.drawPath(path, borderPaint);

    // Bottom (Blue)
    path = Path(); path.moveTo(dx, dy + size); path.lineTo(dx + size, dy + size); path.lineTo(dx + size / 2, dy + size / 2); path.close();
    canvas.drawPath(path, Paint()..color = blueBase);
    canvas.drawPath(path, borderPaint);

    // Left (Red)
    path = Path(); path.moveTo(dx, dy); path.lineTo(dx, dy + size); path.lineTo(dx + size / 2, dy + size / 2); path.close();
    canvas.drawPath(path, Paint()..color = redBase);
    canvas.drawPath(path, borderPaint);
  }

  void _drawBase(Canvas canvas, double dx, double dy, double cellSize, Color color) {
    // Outer colored square
    Rect outerRect = Rect.fromLTWH(dx, dy, cellSize * 6, cellSize * 6);
    canvas.drawRect(outerRect, Paint()..color = color);
    canvas.drawRect(outerRect, Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 2);

    // Inner white square
    Rect innerRect = Rect.fromLTWH(dx + cellSize * 1.2, dy + cellSize * 1.2, cellSize * 3.6, cellSize * 3.6);
    canvas.drawRRect(RRect.fromRectAndRadius(innerRect, const Radius.circular(8)), Paint()..color = Colors.white);

    // 4 spawn spots
    _drawSpawnCircle(canvas, dx + cellSize * 1.6, dy + cellSize * 1.6, cellSize * 1.2, color);
    _drawSpawnCircle(canvas, dx + cellSize * 3.2, dy + cellSize * 1.6, cellSize * 1.2, color);
    _drawSpawnCircle(canvas, dx + cellSize * 1.6, dy + cellSize * 3.2, cellSize * 1.2, color);
    _drawSpawnCircle(canvas, dx + cellSize * 3.2, dy + cellSize * 3.2, cellSize * 1.2, color);
  }

  void _drawSpawnCircle(Canvas canvas, double dx, double dy, double size, Color color) {
    Rect rect = Rect.fromLTWH(dx, dy, size, size);
    
    // White inner background
    canvas.drawOval(rect, Paint()..color = color);
    canvas.drawOval(rect, Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1);
    
    // Small inner dot for depth
    Rect inner = rect.deflate(size * 0.3);
    canvas.drawOval(inner, Paint()..color = Colors.black12);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
