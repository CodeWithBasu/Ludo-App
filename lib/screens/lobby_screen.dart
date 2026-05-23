import 'package:flutter/material.dart';
import 'package:ludo_app/services/firebase_service.dart';
import 'package:ludo_app/screens/game_screen.dart';
import 'package:ludo_app/models/player.dart';

class LobbyScreen extends StatefulWidget {
  final int playerCount;
  final PlayerColor hostColor;
  const LobbyScreen({super.key, this.playerCount = 4, this.hostColor = PlayerColor.red});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  String? _hostedRoomCode;
  bool _isLoading = false;

  void _hostGame() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name first')));
      return;
    }
    setState(() => _isLoading = true);
    
    try {
      String code = await FirebaseService.createRoom(_nameController.text.trim(), widget.playerCount, widget.hostColor);
      setState(() {
        _hostedRoomCode = code;
        _isLoading = false;
      });
      
      // Start listening for someone to join
      FirebaseService.listenToRoom(code).listen((data) {
        if (data != null && data['status'] == 'playing') {
          // A guest joined! Navigate to game screen as HOST (Player 1)
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GameScreen(
                isSinglePlayer: false,
                isOnline: true,
                roomCode: code,
                isHost: true,
                playerCount: widget.playerCount,
                hostColor: widget.hostColor,
              )),
            );
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _joinGame() async {
    if (_nameController.text.trim().isEmpty || _codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter name and room code')));
      return;
    }
    setState(() => _isLoading = true);
    
    try {
      String code = _codeController.text.trim().toUpperCase();
      bool success = await FirebaseService.joinRoom(code, _nameController.text.trim());
      
      if (success) {
        // Navigate to game screen as GUEST (Player 2)
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GameScreen(
              isSinglePlayer: false,
              isOnline: true,
              roomCode: code,
              isHost: false,
              playerCount: widget.playerCount,
              hostColor: widget.hostColor,
            )),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room not found or already full')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Lobby'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D256C), Color(0xFF061440)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _hostedRoomCode != null 
                    ? _buildWaitingRoom() 
                    : _buildLobbyControls(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLobbyControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Join or Host a Match', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Your Name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hostGame,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.all(16)),
                  child: const Text('HOST A GAME', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('OR', style: TextStyle(fontWeight: FontWeight.bold))),
        TextField(
          controller: _codeController,
          decoration: const InputDecoration(labelText: 'Room Code', border: OutlineInputBorder()),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _joinGame,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(16)),
            child: const Text('JOIN GAME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingRoom() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Waiting for Opponent...', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
        const SizedBox(height: 30),
        const CircularProgressIndicator(),
        const SizedBox(height: 30),
        const Text('Share this code with your friend:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo, width: 2),
          ),
          child: Text(
            _hostedRoomCode!,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.indigo),
          ),
        ),
      ],
    );
  }
}
