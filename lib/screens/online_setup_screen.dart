import 'package:flutter/material.dart';
import 'package:ludo_app/screens/lobby_screen.dart';

class OnlineSetupScreen extends StatefulWidget {
  const OnlineSetupScreen({super.key});

  @override
  State<OnlineSetupScreen> createState() => _OnlineSetupScreenState();
}

class _OnlineSetupScreenState extends State<OnlineSetupScreen> {
  final PageController _pageController = PageController();
  
  // Header State
  final int _coins = 1985;
  final int _diamonds = 150;

  // Step 1 State
  String _selectedMode = 'CLASSIC';
  
  // Step 2 State
  int _selectedTokenIndex = 0;
  int _selectedColorIndex = 0;
  final List<Color> _playerColors = [Colors.blue, Colors.red, Colors.green, Colors.amber];
  
  int _selectedPlayers = 2; // 2 or 4
  bool _is5P6P = false;
  
  int _entryFee = 1000;
  int _winAmount = 1900;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateBet(int change) {
    setState(() {
      _entryFee += change;
      if (_entryFee < 500) _entryFee = 500;
      if (_entryFee > 50000) _entryFee = 50000;
      
      // Calculate win: Total pool minus 5% fee (e.g. 1000*2 = 2000 -> 1900)
      _winAmount = (_entryFee * _selectedPlayers * 0.95).round();
    });
  }

  void _onPlayersChanged(int players) {
    setState(() {
      _selectedPlayers = players;
      _updateBet(0); // Recalculate win amount
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B19), // Dark background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe, use buttons
                children: [
                  _buildStep1(),
                  _buildStep2(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text('$_coins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: const Text('SELECT THEME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Row(
            children: [
              const Icon(Icons.diamond, color: Colors.lightBlue, size: 28),
              const SizedBox(width: 8),
              Text('$_diamonds', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 1: SELECT GAME MODE
  // ==========================================
  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF003B8A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 3),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32), // Spacer
                      const Text(
                        'SELECT GAME',
                        style: TextStyle(color: Colors.amber, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2, shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2))]),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                        child: const Icon(Icons.question_mark, color: Color(0xFF003B8A), size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  _buildModeOption('QUICK', Icons.speed, '54855', isPopular: false),
                  const SizedBox(height: 16),
                  _buildModeOption('CLASSIC', Icons.emoji_events, '23004', isPopular: true),
                  const SizedBox(height: 16),
                  _buildModeOption('POPULAR', Icons.refresh, '16102', isPopular: false),
                  const SizedBox(height: 16),
                  _buildModeOption('MASK MODE', Icons.masks, '270', isPopular: false),
                ],
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              },
              child: _buildActionButton('Next'),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF003B8A), size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(String title, IconData rightIcon, String players, {required bool isPopular}) {
    bool isSelected = _selectedMode == title;
    
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedMode = title),
          child: Row(
            children: [
              // Radio Circle
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF003B8A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 4),
                ),
                child: isSelected ? const Center(child: Icon(Icons.check, color: Colors.amber, size: 24)) : null,
              ),
              const SizedBox(width: 12),
              
              // Pill Button
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected 
                          ? [const Color(0xFF005CDB), const Color(0xFF0084FF)] 
                          : [const Color(0xFF002255), const Color(0xFF0044AA)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.amber, width: 2),
                    boxShadow: isSelected ? const [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))] : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1, shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(0, 2))]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Right Icon Box
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Icon(rightIcon, color: Colors.white, size: 24),
                  ),
                  if (isPopular)
                    Positioned(
                      bottom: -15,
                      child: Image.network('https://cdn-icons-png.flaticon.com/512/3135/3135673.png', width: 40, height: 40),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('Players: $players', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // STEP 2: DETAILS (TOKEN, PLAYERS, BET)
  // ==========================================
  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // BOX 1: Token / Color
            _buildBoxWrapper(
              title: 'SELECT TOKEN / COLOR',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.arrow_left, color: Colors.amber, size: 36),
                      _buildTokenOption(0, Icons.location_on, true),
                      _buildTokenOption(1, Icons.flash_on, false),
                      _buildTokenOption(2, Icons.umbrella, false),
                      _buildTokenOption(3, Icons.face_retouching_natural, false),
                      const Icon(Icons.arrow_right, color: Colors.amber, size: 36),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white30, thickness: 2, indent: 40, endIndent: 40),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) => _buildColorOption(index)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // BOX 2: Select Players
            _buildBoxWrapper(
              title: 'SELECT PLAYERS',
              child: Column(
                children: [
                  _buildPlayerRadio(2, '2 PLAYERS'),
                  const SizedBox(height: 16),
                  _buildPlayerRadio(4, '4 PLAYERS'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('5P/6P : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Switch(
                        value: _is5P6P,
                        onChanged: (val) => setState(() => _is5P6P = val),
                        activeColor: Colors.amber,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.shade800,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // BOX 3: Select Game (Bet)
            _buildBoxWrapper(
              title: 'SELECT GAME',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBetButton(Icons.remove, () => _updateBet(-500)),
                      const SizedBox(width: 16),
                      Container(
                        width: 140,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B9D19), // Greenish gold
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                const Text('WIN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${_winAmount ~/ 1000},${(_winAmount % 1000).toString().padLeft(3, '0')}', 
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                                ),
                              ),
                            ),
                            Text(
                              'Entry: ${_entryFee ~/ 1000},${(_entryFee % 1000).toString().padLeft(3, '0')}',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildBetButton(Icons.add, () => _updateBet(500)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Lobby/Game with parameters
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LobbyScreen()),
                      );
                    },
                    child: _buildActionButton('Play'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF003B8A), size: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxWrapper({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF003B8A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTokenOption(int index, IconData icon, bool isUnlocked) {
    bool isSelected = _selectedTokenIndex == index;
    return GestureDetector(
      onTap: isUnlocked ? () => setState(() => _selectedTokenIndex = index) : null,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white24 : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isUnlocked ? Colors.blueAccent : Colors.grey, size: 48),
          ),
          if (!isUnlocked)
            const Positioned(
              top: -5, right: -5,
              child: Icon(Icons.lock, color: Colors.amber, size: 20),
            ),
          if (isSelected)
            const Positioned(
              top: -5, left: -5,
              child: Icon(Icons.check_box, color: Colors.amber, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildColorOption(int index) {
    bool isSelected = _selectedColorIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: _playerColors[index],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: isSelected ? 3 : 0),
          boxShadow: isSelected ? const [BoxShadow(color: Colors.white, blurRadius: 10)] : [],
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
      ),
    );
  }

  Widget _buildPlayerRadio(int count, String label) {
    bool isSelected = _selectedPlayers == count;
    return GestureDetector(
      onTap: () => _onPlayersChanged(count),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF003B8A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber, width: 3),
            ),
            child: isSelected ? const Center(child: Icon(Icons.check, color: Colors.amber, size: 20)) : null,
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildBetButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF002255),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _buildActionButton(String text) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF005CDB), Color(0xFF0084FF)]),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.amber, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1, shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2))]),
      ),
    );
  }
}
