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
      child: SizedBox(
        width: size * 1.2,
        height: size * 1.5,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Shadow
            Positioned(
              top: 4, left: 2,
              child: Icon(Icons.location_on, color: Colors.black.withOpacity(0.6), size: size * 1.2),
            ),
            // White Outer Pin
            Icon(Icons.location_on, color: Colors.white, size: size * 1.2),
            // Colored Inner Pin
            Positioned(
              top: size * 0.1,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [lightColor, baseColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(Icons.location_on, color: Colors.white, size: size * 0.95),
              ),
            ),
            // Dark Center Dot
            Positioned(
              top: size * 0.35,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26, width: 1),
                  boxShadow: const [BoxShadow(color: Colors.white54, blurRadius: 2)],
                ),
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
