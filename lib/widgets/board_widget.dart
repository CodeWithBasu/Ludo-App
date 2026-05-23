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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13), // slightly less than container to fit inside border
          child: CustomPaint(
            painter: BoardPainter(),
          ),
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final Color redBase = const Color(0xFFE52E2D);
  final Color greenBase = const Color(0xFF1EA447);
  final Color yellowBase = const Color(0xFFF2D11B);
  final Color blueBase = const Color(0xFF30A3E6);
  final Color gridLineColor = Colors.black;
  final double strokeWidth = 2.5;

  void _drawTile(Canvas canvas, Rect rect, {Color? color}) {
    // Draw base tile
    final Paint fillPaint = Paint()..color = color ?? Colors.white;
    canvas.drawRect(rect, fillPaint);
    
    // Draw thick black border
    final Paint borderPaint = Paint()
      ..color = gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRect(rect, borderPaint);
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

        // Red Home Path
        if (i == 7 && j >= 1 && j <= 5) tileColor = redBase;
        // Green Home Path
        if (j == 7 && i >= 1 && i <= 5) tileColor = greenBase;
        // Yellow Home Path
        if (i == 7 && j >= 9 && j <= 13) tileColor = yellowBase;
        // Blue Home Path
        if (j == 7 && i >= 9 && i <= 13) tileColor = blueBase;

        // Start Tiles (Colored Safe)
        if (i == 6 && j == 1) tileColor = redBase;
        if (i == 1 && j == 8) tileColor = greenBase;
        if (i == 8 && j == 13) tileColor = yellowBase;
        if (i == 13 && j == 6) tileColor = blueBase;

        _drawTile(canvas, rect, color: tileColor);
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
    final Paint borderPaint = Paint()..color = gridLineColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    
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
    canvas.drawRect(outerRect, Paint()..color = gridLineColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth);

    // Inner white rounded rectangle
    Rect innerRect = Rect.fromLTWH(dx + cellSize * 0.9, dy + cellSize * 0.9, cellSize * 4.2, cellSize * 4.2);
    RRect roundedInner = RRect.fromRectAndRadius(innerRect, const Radius.circular(16));
    canvas.drawRRect(roundedInner, Paint()..color = Colors.white);
    canvas.drawRRect(roundedInner, Paint()..color = gridLineColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth);

    // 4 spawn spots
    _drawSpawnCircle(canvas, dx + cellSize * 1.6, dy + cellSize * 1.6, cellSize * 1.2, color);
    _drawSpawnCircle(canvas, dx + cellSize * 3.2, dy + cellSize * 1.6, cellSize * 1.2, color);
    _drawSpawnCircle(canvas, dx + cellSize * 1.6, dy + cellSize * 3.2, cellSize * 1.2, color);
    _drawSpawnCircle(canvas, dx + cellSize * 3.2, dy + cellSize * 3.2, cellSize * 1.2, color);
  }

  void _drawSpawnCircle(Canvas canvas, double dx, double dy, double size, Color color) {
    Rect rect = Rect.fromLTWH(dx, dy, size, size);
    
    // Colored inner background
    canvas.drawOval(rect, Paint()..color = color);
    // Thick black border
    canvas.drawOval(rect, Paint()..color = gridLineColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
