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

  Map<String, dynamic> toJson() => {
    'id': id,
    'color': color.name,
    'position': position,
    'state': state.name,
  };

  factory Pawn.fromJson(Map<String, dynamic> json) {
    return Pawn(
      id: json['id'],
      color: PlayerColor.values.firstWhere((e) => e.name == json['color']),
      position: json['position'],
      state: PawnState.values.firstWhere((e) => e.name == json['state']),
    );
  }
}
