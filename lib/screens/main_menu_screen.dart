import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ludo_app/screens/game_screen.dart';
import 'package:ludo_app/screens/lobby_screen.dart';
import 'package:ludo_app/screens/profile_screen.dart';
import 'package:ludo_app/services/auth_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _selectedIndex = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    // Listen to auth state so avatar updates immediately after sign-in
    AuthService().authStateChanges().listen((user) {
      if (mounted) setState(() => _currentUser = user);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showComingSoonDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This feature is coming soon!', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('SETTINGS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.purpleAccent),
              title: const Text('Music', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Switch(value: true, onChanged: (v) {}, activeColor: Colors.purpleAccent),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up, color: Colors.blueAccent),
              title: const Text('Sound Effects', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Switch(value: true, onChanged: (v) {}, activeColor: Colors.blueAccent),
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.greenAccent),
              title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Switch(value: false, onChanged: (v) {}, activeColor: Colors.greenAccent),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Vibrant Animated Gradient Background
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFF00C9FF), Color(0xFF92FE9D)],
                    stops: const [0.0, 0.4, 0.8, 1.0],
                    begin: Alignment(0, -1 + 2 * _animController.value),
                    end: Alignment(0, 1 + 2 * _animController.value),
                  ),
                ),
              );
            },
          ),
          // Glass overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildCurrentTab(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentTab() {
    if (_selectedIndex != 0) {
      String title = ['Home', 'Events', 'Social', 'Inventory', 'Store'][_selectedIndex];
      IconData icon = [Icons.home, Icons.event, Icons.chat, Icons.inventory, Icons.store][_selectedIndex];
      
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              Text(title.toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
              const SizedBox(height: 10),
              const Text('Coming Soon', style: TextStyle(fontSize: 18, color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildLogoArea(),
          const SizedBox(height: 30),
          _buildMainButtons(context),
          const SizedBox(height: 20),
          _buildSecondaryButtons(),
          const SizedBox(height: 20),
          _buildBottomExtras(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Profile Icon — shows Google photo if signed in
          GestureDetector(
            onTap: _showProfileDialog,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: _currentUser?.photoURL != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        _currentUser!.photoURL!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, color: Colors.white, size: 36),
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 32),
            onPressed: _showSettingsSheet,
          ),
          const Spacer(),
          _buildCurrencyPill(Icons.diamond, Colors.lightBlueAccent, '50'),
          const SizedBox(width: 8),
          _buildCurrencyPill(Icons.monetization_on, Colors.amber, '2,250'),
        ],
      ),
    );
  }

  Widget _buildCurrencyPill(IconData icon, Color iconColor, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Text(
            amount,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 4; // Store
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoArea() {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10)),
              BoxShadow(color: Colors.purpleAccent, blurRadius: 30),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset('assets/icon.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'LUDO MASTER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
              const Shadow(color: Colors.purpleAccent, blurRadius: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGameButton(
                  title: 'PLAY ONLINE',
                  icon: Icons.language,
                  color: Colors.purpleAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LobbyScreen()));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGameButton(
                  title: 'WITH FRIENDS',
                  icon: Icons.people,
                  color: Colors.blueAccent,
                  onTap: () => _showComingSoonDialog('Play With Friends'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGameButton(
                  title: 'VS COMPUTER',
                  icon: Icons.computer,
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen(isSinglePlayer: true)));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGameButton(
                  title: 'PASS N PLAY',
                  icon: Icons.group,
                  color: Colors.greenAccent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen(isSinglePlayer: false)));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameButton({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 20,
              child: Icon(icon, size: 60, color: Colors.white),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleButton(Icons.local_play, 'TOURNAMENT', Colors.pinkAccent, () => _showComingSoonDialog('Tournament')),
        _buildCircleButton(Icons.escalator, 'SNAKES', Colors.cyanAccent, () => _showComingSoonDialog('Snakes and Ladders')),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.8),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildBottomExtras() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(Icons.monetization_on, 'FREE COINS', Colors.amber, () => _showComingSoonDialog('Free Coins')),
          GestureDetector(
            onTap: () => _showComingSoonDialog('Daily Rewards'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.deepOrangeAccent, blurRadius: 15)],
              ),
              child: const Text('CLAIM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 2)),
            ),
          ),
          _buildCircleButton(Icons.rotate_right, 'SPIN', Colors.purpleAccent, () => _showComingSoonDialog('Lucky Spin')),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: 'HOME'),
              BottomNavigationBarItem(icon: Icon(Icons.event, size: 28), label: 'EVENT'),
              BottomNavigationBarItem(icon: Icon(Icons.chat, size: 28), label: 'SOCIAL'),
              BottomNavigationBarItem(icon: Icon(Icons.inventory, size: 28), label: 'INVENTORY'),
              BottomNavigationBarItem(icon: Icon(Icons.store, size: 28), label: 'STORE'),
            ],
          ),
        ),
      ),
    );
  }
}
