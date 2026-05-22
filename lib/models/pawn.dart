import 'package:ludo_app/models/player.dart';

enum PawnState {
  atBase,
  inPlay,
  atHome,
}

class Pawn {
  final String id;
  final PlayerColor color;
  
  /// Current position of the pawn on the board (0-56).
  /// -1 means it is at the base.
  int position;
  PawnState state;

  Pawn({
    required this.id,
    required this.color,
    this.position = -1,
    this.state = PawnState.atBase,
  });

  void reset() {
    position = -1;
    state = PawnState.atBase;
  }
}
