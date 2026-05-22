import 'package:flutter/material.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: CustomPaint(
          painter: BoardPainter(),
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final Paint _borderPaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final Paint _redPaint = Paint()..color = const Color(0xFFF44336);
  final Paint _greenPaint = Paint()..color = const Color(0xFF4CAF50);
  final Paint _yellowPaint = Paint()..color = const Color(0xFFFFEB3B);
  final Paint _bluePaint = Paint()..color = const Color(0xFF2196F3);
  final Paint _whitePaint = Paint()..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    double cellSize = size.width / 15;

    // Draw the base areas (6x6)
    _drawBase(canvas, 0, 0, cellSize, _redPaint);
    _drawBase(canvas, 9 * cellSize, 0, cellSize, _greenPaint);
    _drawBase(canvas, 0, 9 * cellSize, cellSize, _bluePaint);
    _drawBase(canvas, 9 * cellSize, 9 * cellSize, cellSize, _yellowPaint);

    // Draw the home area in the center (3x3)
    _drawHome(canvas, 6 * cellSize, 6 * cellSize, cellSize * 3);

    // Draw the vertical paths (top and bottom)
    _drawVerticalPath(canvas, 6 * cellSize, 0, cellSize, _greenPaint); // Top path
    _drawVerticalPath(canvas, 6 * cellSize, 9 * cellSize, cellSize, _bluePaint); // Bottom path

    // Draw the horizontal paths (left and right)
    _drawHorizontalPath(canvas, 0, 6 * cellSize, cellSize, _redPaint); // Left path
    _drawHorizontalPath(canvas, 9 * cellSize, 6 * cellSize, cellSize, _yellowPaint); // Right path
  }

  void _drawBase(Canvas canvas, double dx, double dy, double cellSize, Paint colorPaint) {
    // Background color
    canvas.drawRect(Rect.fromLTWH(dx, dy, cellSize * 6, cellSize * 6), colorPaint);
    canvas.drawRect(Rect.fromLTWH(dx, dy, cellSize * 6, cellSize * 6), _borderPaint);
    
    // Inner white box
    canvas.drawRect(Rect.fromLTWH(dx + cellSize, dy + cellSize, cellSize * 4, cellSize * 4), _whitePaint);
    canvas.drawRect(Rect.fromLTWH(dx + cellSize, dy + cellSize, cellSize * 4, cellSize * 4), _borderPaint);

    // 4 spawn circles
    _drawSpawnCircle(canvas, dx + cellSize * 1.5, dy + cellSize * 1.5, cellSize, colorPaint);
    _drawSpawnCircle(canvas, dx + cellSize * 3.5, dy + cellSize * 1.5, cellSize, colorPaint);
    _drawSpawnCircle(canvas, dx + cellSize * 1.5, dy + cellSize * 3.5, cellSize, colorPaint);
    _drawSpawnCircle(canvas, dx + cellSize * 3.5, dy + cellSize * 3.5, cellSize, colorPaint);
  }

  void _drawSpawnCircle(Canvas canvas, double cx, double cy, double cellSize, Paint colorPaint) {
    // Add white background for the circle to pop
    canvas.drawRect(Rect.fromLTWH(cx, cy, cellSize, cellSize), _whitePaint);
    canvas.drawRect(Rect.fromLTWH(cx, cy, cellSize, cellSize), _borderPaint);
    canvas.drawCircle(Offset(cx + cellSize / 2, cy + cellSize / 2), cellSize / 2 - 2, colorPaint);
    canvas.drawCircle(Offset(cx + cellSize / 2, cy + cellSize / 2), cellSize / 2 - 2, _borderPaint);
  }

  void _drawHome(Canvas canvas, double dx, double dy, double size) {
    Path path = Path();
    
    // Top triangle (Green)
    path.moveTo(dx, dy);
    path.lineTo(dx + size, dy);
    path.lineTo(dx + size / 2, dy + size / 2);
    path.close();
    canvas.drawPath(path, _greenPaint);
    canvas.drawPath(path, _borderPaint);

    // Right triangle (Yellow)
    path = Path();
    path.moveTo(dx + size, dy);
    path.lineTo(dx + size, dy + size);
    path.lineTo(dx + size / 2, dy + size / 2);
    path.close();
    canvas.drawPath(path, _yellowPaint);
    canvas.drawPath(path, _borderPaint);

    // Bottom triangle (Blue)
    path = Path();
    path.moveTo(dx, dy + size);
    path.lineTo(dx + size, dy + size);
    path.lineTo(dx + size / 2, dy + size / 2);
    path.close();
    canvas.drawPath(path, _bluePaint);
    canvas.drawPath(path, _borderPaint);

    // Left triangle (Red)
    path = Path();
    path.moveTo(dx, dy);
    path.lineTo(dx, dy + size);
    path.lineTo(dx + size / 2, dy + size / 2);
    path.close();
    canvas.drawPath(path, _redPaint);
    canvas.drawPath(path, _borderPaint);
  }

  void _drawVerticalPath(Canvas canvas, double dx, double dy, double cellSize, Paint homeColor) {
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 3; j++) {
        Rect rect = Rect.fromLTWH(dx + j * cellSize, dy + i * cellSize, cellSize, cellSize);
        
        // Color the home stretch
        if (j == 1 && i != 0 && i != 5) {
          canvas.drawRect(rect, homeColor);
        } else {
          canvas.drawRect(rect, _whitePaint);
        }
        
        // Draw starting arrows / colors (simplified as safe spots)
        // Adjust for specific colors depending on top/bottom
        if ((homeColor == _greenPaint && j == 2 && i == 1) || 
            (homeColor == _bluePaint && j == 0 && i == 4)) {
          canvas.drawRect(rect, homeColor);
        }

        canvas.drawRect(rect, _borderPaint);
      }
    }
  }

  void _drawHorizontalPath(Canvas canvas, double dx, double dy, double cellSize, Paint homeColor) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 6; j++) {
        Rect rect = Rect.fromLTWH(dx + j * cellSize, dy + i * cellSize, cellSize, cellSize);
        
        // Color the home stretch
        if (i == 1 && j != 0 && j != 5) {
          canvas.drawRect(rect, homeColor);
        } else {
          canvas.drawRect(rect, _whitePaint);
        }

        // Draw starting arrows / colors
        if ((homeColor == _redPaint && i == 1 && j == 1) || 
            (homeColor == _yellowPaint && i == 1 && j == 4)) {
           // We'll just draw the starting box color for now
        } else if ((homeColor == _redPaint && i == 0 && j == 1) || 
                   (homeColor == _yellowPaint && i == 2 && j == 4)) {
          canvas.drawRect(rect, homeColor);
        }

        canvas.drawRect(rect, _borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
