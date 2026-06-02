import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:async';
import 'backup_auth_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  DateTime _now = DateTime.now();
  Timer? _timer;
  bool _isUnlocking = false;
  bool _hasFailed = false;
  int _attempts = 0;
  
  String _unlockCommand = 'Unlock the phone';
  String _activeBackupMethod = 'None';
  String _statusMessage = 'Loading...';
  
  bool _isVoiceLockEnabled = true;
  double _sensitivityPercent = 85.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isVoiceLockEnabled = prefs.getBool('is_voice_lock_enabled') ?? true;
      _unlockCommand = prefs.getString('unlock_command') ?? 'Unlock the phone';
      _activeBackupMethod = prefs.getString('active_backup_method') ?? 'None';
      _sensitivityPercent = prefs.getDouble('sensitivity_percent') ?? 85.0;
      
      if (!_isVoiceLockEnabled) {
        _hasFailed = true;
        _statusMessage = 'Voice Lock Disabled';
      } else {
        _statusMessage = 'Say "$_unlockCommand"';
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _simulateVoiceUnlock() async {
    if (_isUnlocking || !_isVoiceLockEnabled) return;
    
    setState(() {
      _isUnlocking = true;
      _statusMessage = 'Listening...';
      _hasFailed = false;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _statusMessage = 'Voice Detected');

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _statusMessage = 'Verifying Speaker & Command...');

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    _attempts++;
    
    // Simulate logic based on sensitivity
    // E.g., if sensitivity is extremely high (> 90%), simulate a failure on the first 2 attempts
    bool simulateSuccess = true;
    if (_sensitivityPercent > 90 && _attempts < 3) {
      simulateSuccess = false;
    } else if (_sensitivityPercent > 70 && _attempts < 2) {
      simulateSuccess = false;
    }

    if (!simulateSuccess) {
      setState(() {
        _isUnlocking = false;
        _statusMessage = 'Verification Failed (Score < ${_sensitivityPercent.toInt()}%)';
        _hasFailed = true;
      });
    } else {
      setState(() {
        _statusMessage = 'Access Granted';
        _hasFailed = false;
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(_now);
    final dateString = DateFormat('EEEE, MMMM d').format(_now);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _simulateVoiceUnlock, 
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF141416), Colors.black],
                  ),
                ),
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.lock_rounded, color: Colors.white, size: 20)
                            .animate(target: _isUnlocking && !_hasFailed ? 1 : 0)
                            .shake(duration: const Duration(milliseconds: 500))
                            .then(delay: const Duration(seconds: 2))
                            .custom(
                                builder: (context, value, child) => Icon(
                                    value == 1 ? Icons.lock_open_rounded : Icons.lock_rounded,
                                    color: Colors.white, size: 20)),
                        const Row(
                          children: [
                            Text('85%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(width: 4),
                            Icon(Icons.battery_6_bar_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  Text(
                    timeString,
                    style: GoogleFonts.inter(
                      fontSize: 86,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
                  
                  Text(
                    dateString,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 200), duration: const Duration(milliseconds: 800)),
                  
                  const Spacer(),
                  
                  if (_hasFailed && _activeBackupMethod != 'None') ...[
                    Column(
                      children: [
                        if (_activeBackupMethod == 'PIN')
                          _buildBackupOption(context, 'Unlock with PIN', Icons.dialpad_rounded, 'PIN'),
                        if (_activeBackupMethod == 'Pattern')
                          _buildBackupOption(context, 'Unlock with Pattern', Icons.pattern_rounded, 'Pattern'),
                        if (_activeBackupMethod == 'Password')
                          _buildBackupOption(context, 'Unlock with Password', Icons.password_rounded, 'Password'),
                      ],
                    ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 30),
                  ],
                  
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: !_isVoiceLockEnabled 
                                ? Colors.white.withOpacity(0.05)
                                : (_isUnlocking 
                                  ? Colors.blue.withOpacity(0.2) 
                                  : (_hasFailed ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.1))),
                          boxShadow: [
                            if (_isUnlocking)
                              BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 30, spreadRadius: 5)
                          ]
                        ),
                        child: Icon(
                          !_isVoiceLockEnabled 
                              ? Icons.mic_off_rounded
                              : (_hasFailed ? Icons.warning_rounded : (_isUnlocking ? Icons.graphic_eq_rounded : Icons.mic_none_rounded)),
                          color: !_isVoiceLockEnabled 
                                  ? Colors.white24 
                                  : (_hasFailed ? Colors.redAccent : Colors.white),
                          size: 32,
                        ),
                      ).animate(target: _isUnlocking ? 1 : 0)
                       .scale(end: const Offset(1.2, 1.2), duration: const Duration(milliseconds: 300))
                       .then()
                       .shimmer(duration: const Duration(seconds: 1)),
                       
                      const SizedBox(height: 16),
                      Text(
                        _statusMessage,
                        style: GoogleFonts.inter(
                          color: !_isVoiceLockEnabled 
                                  ? Colors.white54
                                  : (_hasFailed ? Colors.redAccent : (_isUnlocking ? Colors.blueAccent : Colors.white54)),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate(key: ValueKey(_statusMessage)).fadeIn(duration: const Duration(milliseconds: 300)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupOption(BuildContext context, String title, IconData icon, String authType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => BackupAuthScreen(authType: authType)));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70),
                const SizedBox(width: 16),
                Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: Colors.white24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
