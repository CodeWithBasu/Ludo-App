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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _getColor(pawn.color),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(2, 2),
            )
          ],
        ),
        // Inner highlight for 3D effect
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.transparent,
              ],
              center: const Alignment(-0.3, -0.3),
              radius: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColor(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return Colors.red.shade700;
      case PlayerColor.green:
        return Colors.green.shade700;
      case PlayerColor.yellow:
        return Colors.amber.shade700;
      case PlayerColor.blue:
        return Colors.blue.shade700;
    }
  }
}
