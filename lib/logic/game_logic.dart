import 'dart:math';
import 'package:ludo_app/models/game_state.dart';
import 'package:ludo_app/models/player.dart';

class GameLogic {
  static final Random _random = Random();

  /// Rolls the dice, returns a value from 1 to 6
  static void rollDice(GameState state) {
    if (state.diceRolled) return; // Wait for move
    
    state.diceValue = _random.nextInt(6) + 1;
    state.diceRolled = true;

    // Determine if the player can make any moves
    if (!_canMoveAnyPawn(state)) {
      // If no valid moves, skip turn automatically
      nextTurn(state);
    }
  }

  /// Checks if the current player has any valid moves
  static bool _canMoveAnyPawn(GameState state) {
    final pawns = state.pawns[state.currentTurn]!;
    for (var pawn in pawns) {
      if (pawn.position == -1 && state.diceValue == 6) {
        return true; // Can enter board
      }
      if (pawn.position != -1 && pawn.position + state.diceValue <= 56) {
        return true; // Can move forward (56 is center of board)
      }
    }
    return false;
  }

  /// Passes the turn to the next player
  static void nextTurn(GameState state) {
    // If they rolled a 6, they get another turn (usually, unless they won)
    if (state.diceValue == 6) {
      state.diceRolled = false;
      return;
    }

    final colors = PlayerColor.values;
    final currentIndex = colors.indexOf(state.currentTurn);
    final nextIndex = (currentIndex + 1) % colors.length;
    
    state.currentTurn = colors[nextIndex];
    state.diceRolled = false;
  }
}
