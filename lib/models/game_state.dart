import 'package:ludo_app/models/pawn.dart';
import 'package:ludo_app/models/player.dart';

class GameState {
  final List<Player> players;
  final Map<PlayerColor, List<Pawn>> pawns;
  
  PlayerColor currentTurn;
  int diceValue;
  bool diceRolled;
  
  GameState({
    required this.players,
    required this.pawns,
    this.currentTurn = PlayerColor.red,
    this.diceValue = 1,
    this.diceRolled = false,
  });

  /// Factory to initialize a standard game state
  factory GameState.initial({bool isSinglePlayer = false}) {
    final players = [
      Player(id: '1', name: 'Player 1', color: PlayerColor.red),
      Player(id: '2', name: 'Player 2', color: PlayerColor.green, isComputer: isSinglePlayer),
      Player(id: '3', name: 'Player 3', color: PlayerColor.yellow, isComputer: isSinglePlayer),
      Player(id: '4', name: 'Player 4', color: PlayerColor.blue, isComputer: isSinglePlayer),
    ];

    final Map<PlayerColor, List<Pawn>> pawns = {};
    for (var player in players) {
      pawns[player.color] = List.generate(
        4,
        (index) => Pawn(
          id: '${player.color.name}_pawn_$index',
          color: player.color,
        ),
      );
    }

    return GameState(
      players: players,
      pawns: pawns,
      currentTurn: PlayerColor.red,
    );
  }
}
