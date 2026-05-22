import 'package:flutter/material.dart';
import 'package:ludo_app/models/pawn.dart';
import 'package:ludo_app/models/player.dart';

class PawnWidget extends StatelessWidget {
  final Pawn pawn;
  final VoidCallback onTap;
  final double size;

  const PawnWidget({
    super.key,
    required this.pawn,
    required this.onTap,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor = _getColor(pawn.color);
    Color lightColor = _getLightColor(pawn.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            // Strong drop shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: const Offset(2, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // Main 3D Sphere gradient
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [lightColor, baseColor],
                  center: const Alignment(-0.3, -0.4),
                  radius: 0.8,
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            // Glossy plastic highlight
            Positioned(
              top: size * 0.1,
              left: size * 0.15,
              child: Container(
                width: size * 0.4,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.all(Radius.elliptical(size * 0.4, size * 0.2)),
                  // Rotate slightly for curved reflection
                ),
                transform: Matrix4.rotationZ(-0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(PlayerColor color) {
    switch (color) {
      case PlayerColor.red: return const Color(0xFFD32F2F);
      case PlayerColor.green: return const Color(0xFF388E3C);
      case PlayerColor.yellow: return const Color(0xFFFBC02D);
      case PlayerColor.blue: return const Color(0xFF1976D2);
    }
  }

  Color _getLightColor(PlayerColor color) {
    switch (color) {
      case PlayerColor.red: return const Color(0xFFFF5252);
      case PlayerColor.green: return const Color(0xFF69F0AE);
      case PlayerColor.yellow: return const Color(0xFFFFFF00);
      case PlayerColor.blue: return const Color(0xFF448AFF);
    }
  }
}
