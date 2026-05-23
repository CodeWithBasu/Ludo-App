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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ludo_app/services/firebase_service.dart';

class GameScreen extends StatefulWidget {
  final bool isSinglePlayer;
  final bool isOnline;
  final String? roomCode;
  final bool isHost;
  final int playerCount;
  final PlayerColor hostColor;

  const GameScreen({
    super.key, 
    this.isSinglePlayer = false,
    this.isOnline = false,
    this.roomCode,
    this.isHost = true,
    this.playerCount = 4,
    this.hostColor = PlayerColor.red,
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
  
  String _hostName = 'Player 1';
  int _hostAvatar = 0;
  String _hostCountry = 'IN';

  @override
  void initState() {
    super.initState();
    _gameState = GameState.initial(
      isSinglePlayer: widget.isSinglePlayer, 
      playerCount: widget.playerCount,
      hostColor: widget.hostColor,
    );
    
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
    _loadHostProfile();
  }

  Future<void> _loadHostProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _hostName = prefs.getString('profile_name') ?? 'Player 1';
        _hostAvatar = prefs.getInt('profile_avatar') ?? 0;
        _hostCountry = prefs.getString('profile_country') ?? 'IN';
      });
    }
  }

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    super.dispose();
  }

  bool get _isMyTurn {
    if (!widget.isOnline) return true; // Local play, anyone can tap
    if (widget.isHost && _gameState.players.isNotEmpty && _gameState.currentTurn == _gameState.players[0].color) return true;
    if (!widget.isHost && _gameState.players.length > 1 && _gameState.currentTurn == _gameState.players[1].color) return true;
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
      backgroundColor: const Color(0xFF001F54), // Dark blue ludo background
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const NetworkImage('https://i.pinimg.com/736x/87/44/1a/87441a12903ea29e06cd2e519c72e212.jpg'), // Pattern background
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.blue.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double boardSize = constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                        double cellSize = boardSize / 15;

                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
                          ),
                          child: SizedBox(
                            width: boardSize,
                            height: boardSize,
                            child: Stack(
                              children: [
                                const BoardWidget(),
                                ..._buildPawns(boardSize, cellSize),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            widget.isOnline ? 'ROOM: ${widget.roomCode}' : 'PASS & PLAY',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPawns(double boardSize, double cellSize) {
    List<Widget> pawnWidgets = [];
    
    for (var color in PlayerColor.values) {
      if (!_gameState.pawns.containsKey(color)) continue;
      
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2E6E),
        border: Border(top: BorderSide(color: Colors.amber.shade200, width: 2)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: _gameState.players.length == 2
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlayerProfile(_gameState.players[0], true),
                _buildCenterDice(),
                _buildPlayerProfile(_gameState.players[1], false),
              ],
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._gameState.players.map((p) => Padding(padding: const EdgeInsets.only(right: 8), child: _buildPlayerProfile(p, p.id == '1'))),
                  _buildCenterDice(),
                ],
              ),
            ),
    );
  }

  Widget _buildPlayerProfile(Player player, bool isHost) {
    bool isActive = _gameState.currentTurn == player.color;
    
    String name = isHost ? _hostName : 'Opponent';
    String country = isHost ? _hostCountry : 'KR';
    int coins = isHost ? 1985 : 9387;
    String avatarUrl = isHost 
        ? 'https://cdn-icons-png.flaticon.com/512/4140/41400${_hostAvatar + 47}.png'
        : 'https://cdn-icons-png.flaticon.com/512/4140/4140048.png';

    return Container(
      width: 130,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.3) : Colors.transparent,
        border: isActive ? Border.all(color: Colors.greenAccent, width: 2) : Border.all(color: Colors.transparent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: _getColor(player.color), width: 3),
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover),
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: -5, right: -5,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  child: Text(country, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text('$coins', style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterDice() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: _getColor(_gameState.currentTurn).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getColor(_gameState.currentTurn), width: 3),
        boxShadow: [
          BoxShadow(
            color: _getColor(_gameState.currentTurn).withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          DiceWidget(
            key: _diceKey,
            value: _gameState.diceValue,
            onRoll: _rollDice,
            color: _getColor(_gameState.currentTurn),
            enabled: !_gameState.diceRolled && _isMyTurn,
          ),
          if (!_isMyTurn && !_gameState.diceRolled)
            const Positioned(
              bottom: 4,
              child: Text('WAIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
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
