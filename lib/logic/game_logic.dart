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
    // If they rolled a 6, they get another turn (unless they won)
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

  /// Attempts to move a specific pawn
  static bool movePawn(GameState state, Pawn pawn) {
    if (pawn.color != state.currentTurn || !state.diceRolled) return false;

    // Moving out of base
    if (pawn.position == -1) {
      if (state.diceValue == 6) {
        pawn.position = 0; // 0 relative steps taken
        pawn.state = PawnState.inPlay;
        state.diceRolled = false; // They get to roll again for rolling a 6
        return true;
      }
      return false; // Cannot move out of base without a 6
    }

    // Normal move
    int nextPosition = pawn.position + state.diceValue;
    
    // Check if the move is valid
    if (nextPosition > 57) {
      return false; // Overshoots home, cannot move
    }

    pawn.position = nextPosition;
    
    // Check if they reached home
    if (pawn.position == 57) {
      pawn.state = PawnState.atHome;
      // Extra turn for reaching home
      state.diceRolled = false; 
      state.diceValue = 6; // Fake a 6 to give an extra turn, or handle it differently
    } else {
      // Check for captures
      bool captured = _handleCaptures(state, pawn);
      if (captured) {
        // Extra turn for capturing
        state.diceRolled = false;
        state.diceValue = 6;
      }
    }

    if (state.diceRolled) {
      nextTurn(state);
    }
    return true;
  }

  /// Handles pawn captures. Returns true if a capture occurred.
  static bool _handleCaptures(GameState state, Pawn movingPawn) {
    if (movingPawn.position >= 52) return false; // In home stretch, no captures

    int absolutePos = getAbsoluteBoardPosition(movingPawn.color, movingPawn.position);
    if (isSafeSpot(absolutePos)) return false;

    bool captured = false;

    // Check all other pawns
    for (var color in PlayerColor.values) {
      if (color == movingPawn.color) continue; // Skip own pawns

      for (var opponentPawn in state.pawns[color]!) {
        if (opponentPawn.state == PawnState.inPlay && opponentPawn.position < 52) {
          int oppAbsolutePos = getAbsoluteBoardPosition(opponentPawn.color, opponentPawn.position);
          if (absolutePos == oppAbsolutePos) {
            // Capture!
            opponentPawn.reset();
            captured = true;
          }
        }
      }
    }

    return captured;
  }

  /// Converts a relative position (0-51) to an absolute board index (0-51)
  static int getAbsoluteBoardPosition(PlayerColor color, int relativePosition) {
    int startOffset = 0;
    switch (color) {
      case PlayerColor.red:
        startOffset = 0;
        break;
      case PlayerColor.green:
        startOffset = 13;
        break;
      case PlayerColor.yellow:
        startOffset = 26;
        break;
      case PlayerColor.blue:
        startOffset = 39;
        break;
    }
    return (startOffset + relativePosition) % 52;
  }

  /// Checks if an absolute position is a safe spot
  static bool isSafeSpot(int absolutePosition) {
    const safeSpots = [0, 8, 13, 21, 26, 34, 39, 47];
    return safeSpots.contains(absolutePosition);
  }

  /// Returns a list of pawns that can currently make a valid move for the given color
  static List<Pawn> getValidMoves(GameState state, PlayerColor color) {
    if (!state.diceRolled || state.currentTurn != color) return [];

    List<Pawn> validPawns = [];
    for (var pawn in state.pawns[color]!) {
      if (pawn.state == PawnState.atHome) continue;
      
      if (pawn.state == PawnState.atBase) {
        if (state.diceValue == 6) {
          validPawns.add(pawn);
        }
      } else {
        if (pawn.position + state.diceValue <= 57) {
          validPawns.add(pawn);
        }
      }
    }
    return validPawns;
  }
}
