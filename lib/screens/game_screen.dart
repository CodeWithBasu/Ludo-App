import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ludo_app/models/game_state.dart';
import 'package:ludo_app/models/player.dart';
import 'package:ludo_app/models/pawn.dart';
import 'package:ludo_app/logic/game_logic.dart';
import 'package:ludo_app/logic/path_coordinates.dart';
import 'package:ludo_app/widgets/board_widget.dart';
import 'package:ludo_app/widgets/pawn_widget.dart';
import 'package:ludo_app/widgets/dice_widget.dart';

import 'package:ludo_app/services/firebase_service.dart';

class GameScreen extends StatefulWidget {
  final bool isSinglePlayer;
  final bool isOnline;
  final String? roomCode;
  final bool isHost;

  const GameScreen({
    super.key, 
    this.isSinglePlayer = false,
    this.isOnline = false,
    this.roomCode,
    this.isHost = true,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  bool _isAITurning = false;
  
  // We need a GlobalKey to access the DiceWidget state to trigger its animation programmatically
  final GlobalKey<DiceWidgetState> _diceKey = GlobalKey<DiceWidgetState>();

  StreamSubscription? _gameStateSubscription;

  @override
  void initState() {
    super.initState();
    _gameState = GameState.initial(isSinglePlayer: widget.isSinglePlayer);
    
    if (widget.isOnline && widget.roomCode != null) {
      _gameStateSubscription = FirebaseService.listenToGameState(widget.roomCode!).listen((state) {
        if (state != null && mounted) {
          setState(() {
            _gameState = state;
          });
        }
      });
    } else {
      _checkAITurn();
    }
  }

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    super.dispose();
  }

  bool get _isMyTurn {
    if (!widget.isOnline) return true; // Local play, anyone can tap
    if (widget.isHost && _gameState.currentTurn == PlayerColor.red) return true;
    if (!widget.isHost && _gameState.currentTurn == PlayerColor.green) return true;
    return false;
  }

  void _checkAITurn() {
    // If it's a computer's turn and we aren't already processing an AI turn
    Player currentPlayer = _gameState.players.firstWhere((p) => p.color == _gameState.currentTurn);
    if (currentPlayer.isComputer && !_isAITurning) {
      _playAITurn();
    }
  }

  Future<void> _playAITurn() async {
    setState(() {
      _isAITurning = true;
    });

    // Wait a moment so human can see turn changed
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Trigger dice roll animation
    if (!_gameState.diceRolled) {
      _diceKey.currentState?.triggerRoll();
      // The triggerRoll will call _rollDice eventually, which handles state
      // We will wait for animation + a small buffer
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (!mounted) return;

    // Now logic has updated dice value
    List<Pawn> validMoves = GameLogic.getValidMoves(_gameState, _gameState.currentTurn);
    
    if (validMoves.isNotEmpty) {
      // Small pause before moving
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      
      // Simple AI: Random valid move
      Pawn chosenPawn = validMoves[Random().nextInt(validMoves.length)];
      
      setState(() {
        GameLogic.movePawn(_gameState, chosenPawn);
      });
    } else {
      // If no valid moves, we have to skip turn explicitly
      // Actually GameLogic should handle passing turn if no moves, but we can do it here for AI
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        GameLogic.nextTurn(_gameState);
      });
    }

    _isAITurning = false;
    _checkAITurn(); // Check if next player is also AI, or same player rolling a 6
  }

  void _rollDice() {
    if (!_isMyTurn) return;

    setState(() {
      GameLogic.rollDice(_gameState);
    });
    
    if (widget.isOnline) {
      FirebaseService.updateGameState(widget.roomCode!, _gameState);
    }
    // Check if AI needs to move (though mostly human triggers this)
    // Wait, AI will trigger this via diceKey.
    if (_gameState.players.firstWhere((p) => p.color == _gameState.currentTurn).isComputer) {
       // Handled in _playAITurn
    } else {
      // If human rolled, but has no valid moves, we should auto skip turn, 
      // but let's keep it simple for now, they might have to wait or we auto skip.
      List<Pawn> validMoves = GameLogic.getValidMoves(_gameState, _gameState.currentTurn);
      if (validMoves.isEmpty) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              GameLogic.nextTurn(_gameState);
            });
            if (widget.isOnline) {
              FirebaseService.updateGameState(widget.roomCode!, _gameState);
            }
            if (!widget.isOnline) _checkAITurn();
          }
        });
      }
    }
  }

  void _onPawnTapped(Pawn pawn) {
    if (_isAITurning || !_isMyTurn) return; 
    
    setState(() {
      GameLogic.movePawn(_gameState, pawn);
    });
    
    if (widget.isOnline) {
      FirebaseService.updateGameState(widget.roomCode!, _gameState);
    } else {
      _checkAITurn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: Text(widget.isOnline ? 'Online Match: ${widget.roomCode}' : 'Pass & Play'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPlayerInfo(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate the square size for the board
                      double boardSize = constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth
                          : constraints.maxHeight;
                      double cellSize = boardSize / 15;

                      return SizedBox(
                        width: boardSize,
                        height: boardSize,
                        child: Stack(
                          children: [
                            const BoardWidget(),
                            ..._buildPawns(boardSize, cellSize),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            _buildDiceSection(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPawns(double boardSize, double cellSize) {
    List<Widget> pawnWidgets = [];
    
    for (var color in PlayerColor.values) {
      List<Pawn> pawns = _gameState.pawns[color]!;
      for (int i = 0; i < pawns.length; i++) {
        Pawn pawn = pawns[i];
        
        List<int> gridCoords;
        if (pawn.state == PawnState.atBase) {
           gridCoords = PathCoordinates.basePositions[color.name]![i];
        } else if (pawn.state == PawnState.atHome) {
           // Put it near the center home
           gridCoords = [7, 7]; 
        } else {
           if (pawn.position < 52) {
             int absPos = GameLogic.getAbsoluteBoardPosition(pawn.color, pawn.position);
             gridCoords = PathCoordinates.mainPath[absPos];
           } else {
             int homeIndex = pawn.position - 52;
             gridCoords = PathCoordinates.homePaths[pawn.color.name]![homeIndex];
           }
        }

        double x = gridCoords[0] * cellSize + (cellSize * 0.15); // Offset to center pawn
        double y = gridCoords[1] * cellSize + (cellSize * 0.15);

        // Adjust slightly if at home to cluster them
        if (pawn.state == PawnState.atHome) {
          x += (i % 2) * (cellSize * 0.3) - (cellSize * 0.15);
          y += (i ~/ 2) * (cellSize * 0.3) - (cellSize * 0.15);
        }

        pawnWidgets.add(
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: x,
            top: y,
            child: PawnWidget(
              pawn: pawn,
              size: cellSize * 0.7,
              onTap: () => _onPawnTapped(pawn),
            ),
          ),
        );
      }
    }
    return pawnWidgets;
  }

  Widget _buildPlayerInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Current Turn: ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            _gameState.currentTurn.name.toUpperCase(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getColor(_gameState.currentTurn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DiceWidget(
            key: _diceKey,
            value: _gameState.diceValue,
            onRoll: _rollDice,
            color: _getColor(_gameState.currentTurn),
            enabled: !_gameState.diceRolled,
          ),
          ElevatedButton(
            onPressed: (_gameState.diceRolled || !_isMyTurn) ? null : _rollDice,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              backgroundColor: _getColor(_gameState.currentTurn),
              foregroundColor: Colors.white,
            ),
            child: Text(_isMyTurn ? 'ROLL DICE' : 'WAIT', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _getColor(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return Colors.red;
      case PlayerColor.green:
        return Colors.green;
      case PlayerColor.yellow:
        return Colors.amber;
      case PlayerColor.blue:
        return Colors.blue;
    }
  }
}
