import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:ludo_app/models/game_state.dart';
import 'package:ludo_app/models/player.dart';

class FirebaseService {
  static final FirebaseDatabase _db = FirebaseDatabase.instance;
  
  /// Creates a new room and returns the 6-digit room code
  static Future<String> createRoom(String hostName, int playerCount, PlayerColor hostColor) async {
    String roomCode = _generateRoomCode();
    
    // Initial state with dynamic host settings
    GameState initialState = GameState.initial(isSinglePlayer: false, playerCount: playerCount, hostColor: hostColor);
    // Since it's online, we can update the first player's name
    initialState.players[0] = Player(id: 'host', name: hostName, color: hostColor);
    
    await _db.ref('rooms/$roomCode').set({
      'host': hostName,
      'guest': null,
      'status': 'waiting', // waiting, playing, finished
      'state': initialState.toJson(),
      'last_action': ServerValue.timestamp,
    });
    
    return roomCode;
  }

  /// Attempts to join a room. Returns true if successful.
  static Future<bool> joinRoom(String roomCode, String guestName) async {
    DatabaseEvent event = await _db.ref('rooms/$roomCode').once();
    if (event.snapshot.exists) {
      Map data = event.snapshot.value as Map;
      if (data['status'] == 'waiting') {
        // We can join
        await _db.ref('rooms/$roomCode').update({
          'guest': guestName,
          'status': 'playing',
        });
        
        // Update the guest name in the state
        DatabaseEvent stateEvent = await _db.ref('rooms/$roomCode/state').once();
        if (stateEvent.snapshot.exists) {
           GameState state = GameState.fromJson(stateEvent.snapshot.value as Map);
           if (state.players.length > 1) {
             state.players[1] = Player(id: 'guest', name: guestName, color: state.players[1].color);
           }
           await updateGameState(roomCode, state);
        }
        return true;
      }
    }
    return false;
  }

  /// Pushes the new game state to Firebase
  static Future<void> updateGameState(String roomCode, GameState state) async {
    await _db.ref('rooms/$roomCode/state').set(state.toJson());
    await _db.ref('rooms/$roomCode/last_action').set(ServerValue.timestamp);
  }

  /// Listens to real-time updates for a specific room
  static Stream<GameState?> listenToGameState(String roomCode) {
    return _db.ref('rooms/$roomCode/state').onValue.map((event) {
      if (event.snapshot.exists) {
        return GameState.fromJson(event.snapshot.value as Map);
      }
      return null;
    });
  }

  /// Listens to the overall room status (useful for the lobby waiting screen)
  static Stream<Map?> listenToRoom(String roomCode) {
    return _db.ref('rooms/$roomCode').onValue.map((event) {
      if (event.snapshot.exists) {
        return event.snapshot.value as Map;
      }
      return null;
    });
  }

  static String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
