import 'package:flutter/material.dart';
import 'package:ludo_app/screens/game_screen.dart';
import 'dart:math';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D256C), Color(0xFF061440)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          // Profile Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              border: Border.all(color: Colors.yellow, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.settings, color: Colors.white, size: 32),
          const Spacer(),
          // Gems
          _buildCurrencyPill(Icons.diamond, Colors.lightBlueAccent, '50'),
          const SizedBox(width: 8),
          // Coins
          _buildCurrencyPill(Icons.monetization_on, Colors.amber, '2,250'),
        ],
      ),
    );
  }

  Widget _buildCurrencyPill(IconData icon, Color iconColor, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1950),
        border: Border.all(color: Colors.blue.shade900, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 4),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoArea() {
    return Column(
      children: [
        // Crown
        const Icon(Icons.workspace_premium, color: Colors.amber, size: 64),
        // LUDO letters
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoLetter('L', Colors.blue),
            _buildLogoLetter('U', Colors.red),
            _buildLogoLetter('D', Colors.green),
            _buildLogoLetter('O', Colors.yellow),
          ],
        ),
        const SizedBox(height: 8),
        // KING text
        const Text(
          'MASTER',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
          ),
        ),
        const SizedBox(height: 10),
        // Simple Board Graphic Representation
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Just a simple visual to mimic the 3D board
              Row(
                children: [
                  Expanded(child: Container(color: Colors.red.withOpacity(0.8))),
                  Expanded(child: Container(color: Colors.green.withOpacity(0.8))),
                ],
              ),
              const Icon(Icons.casino, size: 48, color: Colors.black87),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoLetter(String letter, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
                  subtitle: 'Players: 113,392',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGameButton(
                  title: 'PLAY WITH FRIENDS',
                  icon: Icons.people,
                  subtitle: 'Players: 22,199',
                  onTap: () {},
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameScreen(isSinglePlayer: true)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGameButton(
                  title: 'PASS N PLAY',
                  icon: Icons.group,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameScreen(isSinglePlayer: false)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameButton({
    required String title,
    required IconData icon,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF003D82), Color(0xFF001A40)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amberAccent, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(2, 4)),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner icon
                Positioned(
                  top: 15,
                  child: Icon(icon, size: 50, color: Colors.white.withOpacity(0.9)),
                ),
                // Title Ribbon
                Positioned(
                  bottom: -2,
                  left: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0A1950),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecondaryButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleButton(Icons.local_play, 'TOURNAMENT'),
        _buildCircleButton(Icons.escalator, 'SNAKES'),
      ],
    );
  }

  Widget _buildCircleButton(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent,
            border: Border.all(color: Colors.amber, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildBottomExtras() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(Icons.monetization_on, 'FREE COINS'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: const Text('CLAIM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          _buildCircleButton(Icons.rotate_right, 'SPIN'),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF001A40),
        border: Border(top: BorderSide(color: Colors.blueAccent, width: 2)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white60,
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
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const double spacing = 60;
    
    // Draw subtle squares with dots inside mimicking dice
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(i + 10, j + 10, spacing - 20, spacing - 20), const Radius.circular(8)),
          paint,
        );
        // Middle dot
        canvas.drawCircle(Offset(i + spacing / 2, j + spacing / 2), 4, Paint()..color = Colors.blueAccent.withOpacity(0.05));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
