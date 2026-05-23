import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedAvatar = 0;
  String _playerName = 'Basudev';
  String _selectedCountry = '🇮🇳 India';
  bool _isLoading = true;

  final List<String> _avatars = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
  ];

  final List<Map<String, String>> _countries = [
    {'flag': '🇮🇳', 'name': 'India'},
    {'flag': '🇺🇸', 'name': 'USA'},
    {'flag': '🇬🇧', 'name': 'UK'},
    {'flag': '🇦🇪', 'name': 'UAE'},
    {'flag': '🇵🇰', 'name': 'Pakistan'},
    {'flag': '🇧🇩', 'name': 'Bangladesh'},
    {'flag': '🇳🇵', 'name': 'Nepal'},
    {'flag': '🇨🇦', 'name': 'Canada'},
    {'flag': '🇦🇺', 'name': 'Australia'},
    {'flag': '🇩🇪', 'name': 'Germany'},
  ];

  final List<Map<String, dynamic>> _stats = [
    {'icon': '👍', 'label': 'GAMES WON', 'value': '4'},
    {'icon': '👎', 'label': 'GAMES LOST', 'value': '2'},
    {'icon': '🏆', 'label': 'WIN STREAK', 'value': '3'},
    {'icon': '🎯', 'label': 'TOKENS CAPTURED', 'value': '29'},
    {'icon': '💥', 'label': 'TOKENS KILLED', 'value': '25'},
    {'icon': '🎖️', 'label': 'PERFORMANCE RATING', 'value': '45'},
    {'icon': '🥇', 'label': 'TOURNAMENTS WON', 'value': '0'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedAvatar = prefs.getInt('profile_avatar') ?? 0;
      _playerName = prefs.getString('profile_name') ?? 'Basudev';
      _selectedCountry = prefs.getString('profile_country') ?? '🇮🇳 India';
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('profile_avatar', _selectedAvatar);
    await prefs.setString('profile_name', _playerName);
    await prefs.setString('profile_country', _selectedCountry);
  }

  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1565C0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Choose Avatar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: _avatars.length,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () async {
                setState(() => _selectedAvatar = i);
                await _saveProfile();
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Avatar saved!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedAvatar == i ? Colors.amber : Colors.white30,
                    width: _selectedAvatar == i ? 4 : 2,
                  ),
                  boxShadow: _selectedAvatar == i
                      ? [const BoxShadow(color: Colors.amber, blurRadius: 12)]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(_avatars[i], fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditName() {
    final ctrl = TextEditingController(text: _playerName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1565C0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            onPressed: () async {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                setState(() => _playerName = newName);
                await _saveProfile();
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Name saved!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              }
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1565C0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Select Country', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView.builder(
            itemCount: _countries.length,
            itemBuilder: (ctx, i) {
              final c = _countries[i];
              final label = '${c['flag']} ${c['name']}';
              return ListTile(
                title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18)),
                onTap: () async {
                  setState(() => _selectedCountry = label);
                  await _saveProfile();
                  Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Country saved!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D47A1),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: SafeArea(
        child: Column(
          children: [
            // Title ribbon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFB71C1C)]),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: const Text(
                'STATISTICS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: 4,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6, offset: Offset(0, 3))],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Player ID bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _showCountryPicker,
                            child: Text(
                              _selectedCountry.split(' ')[0],
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: const Text(
                              '69f722b9a3e864edc0dd4f8c',
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                            onPressed: () {
                              Clipboard.setData(const ClipboardData(text: '69f722b9a3e864edc0dd4f8c'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ID Copied!'), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Profile Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              GestureDetector(
                                onTap: _showAvatarPicker,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFF1565C0), width: 3),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Image.asset(_avatars[_selectedAvatar], fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(color: Color(0xFF1565C0), shape: BoxShape.circle),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name row
                                    Row(
                                      children: [
                                        const Icon(Icons.person, color: Color(0xFF1565C0), size: 18),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            _playerName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF0D47A1)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _showEditName,
                                          child: const Icon(Icons.edit, color: Colors.blueGrey, size: 18),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Coins & Gems
                                    Row(
                                      children: const [
                                        Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                                        SizedBox(width: 4),
                                        Text('1,985', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                                        SizedBox(width: 16),
                                        Icon(Icons.diamond, color: Colors.lightBlue, size: 20),
                                        SizedBox(width: 4),
                                        Text('150', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Country
                                    GestureDetector(
                                      onTap: _showCountryPicker,
                                      child: Row(
                                        children: [
                                          Text(_selectedCountry, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.arrow_drop_down, color: Colors.black45, size: 20),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Status bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Add your status...',
                                      hintStyle: TextStyle(color: Colors.black38),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ),
                                const Icon(Icons.edit, color: Color(0xFF1565C0), size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Level progress
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text('Level 1', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 30),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 0.0,
                                    minHeight: 20,
                                    backgroundColor: Color(0xFF0D47A1),
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text('0/180', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Stats list
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: _stats.map((stat) => _buildStatRow(stat['icon']!, stat['label']!, stat['value']!)).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bottom buttons
                    Row(
                      children: [
                        Expanded(child: _buildActionButton(Icons.cloud_upload, 'Save\nData', Colors.green)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildActionButton(Icons.devices, 'Change\nDevice', Colors.teal)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildActionButton(Icons.diamond, '+100', Colors.lightBlue)),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Facebook login
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1877F2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.facebook, color: Colors.white, size: 28),
                          SizedBox(width: 10),
                          Text('Login with Facebook', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
                                SizedBox(width: 6),
                                Text('Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sports_esports, color: Colors.black54, size: 24),
                                SizedBox(width: 6),
                                Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Edit Profile button
                    GestureDetector(
                      onTap: _showEditName,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.orangeAccent, blurRadius: 10)],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Back button
            Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8F00),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String emoji, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
            ),
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}
