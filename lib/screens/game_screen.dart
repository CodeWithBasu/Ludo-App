import 'package:flutter/material.dart';
import 'package:ludo_app/models/game_state.dart';
import 'package:ludo_app/models/player.dart';
import 'package:ludo_app/models/pawn.dart';
import 'package:ludo_app/logic/game_logic.dart';
import 'package:ludo_app/logic/path_coordinates.dart';
import 'package:ludo_app/widgets/board_widget.dart';
import 'package:ludo_app/widgets/pawn_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _gameState = GameState.initial();
  }

  void _rollDice() {
    setState(() {
      GameLogic.rollDice(_gameState);
    });
  }

  void _onPawnTapped(Pawn pawn) {
    setState(() {
      GameLogic.movePawn(_gameState, pawn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: const Text('Pass & Play'),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black26, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                '${_gameState.diceValue}',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _gameState.diceRolled ? null : _rollDice,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              backgroundColor: _getColor(_gameState.currentTurn),
              foregroundColor: Colors.white,
            ),
            child: const Text('ROLL DICE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
