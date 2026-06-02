import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../settings/settings_screen.dart';
import '../lockscreen/lock_screen.dart';

enum VoiceState {
  idle,
  disabled,
  listening,
  processing,
  voiceDetected,
  commandRecognized,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VoiceState _currentState = VoiceState.idle;
  String _lockCommand = "Lock the phone";
  bool _isVoiceLockEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadCustomCommand();
  }

  Future<void> _loadCustomCommand() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isVoiceLockEnabled = prefs.getBool('is_voice_lock_enabled') ?? true;
      _lockCommand = prefs.getString('lock_command') ?? "Lock the phone";
      if (!_isVoiceLockEnabled) {
        _currentState = VoiceState.disabled;
      } else {
        _currentState = VoiceState.idle;
      }
    });
  }

  void _onMicTapped() async {
    if (_currentState == VoiceState.disabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice Screen Lock is disabled in Settings.')),
      );
      return;
    }
    if (_currentState != VoiceState.idle) return;

    // Refresh command in case it was changed in Settings
    await _loadCustomCommand();
    
    if (!_isVoiceLockEnabled) return;

    setState(() => _currentState = VoiceState.listening);
    
    // Simulate voice detection
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _currentState = VoiceState.voiceDetected);

    // Simulate processing
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _currentState = VoiceState.processing);

    // Simulate command recognized
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _currentState = VoiceState.commandRecognized);

    // Navigate to lock screen
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    
    setState(() => _currentState = VoiceState.idle);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LockScreen()));
  }

  String _getStatusText() {
    switch (_currentState) {
      case VoiceState.idle:
        return 'Tap to speak "$_lockCommand"';
      case VoiceState.disabled:
        return 'Voice Lock Disabled';
      case VoiceState.listening:
        return 'Listening...';
      case VoiceState.voiceDetected:
        return 'Voice Detected';
      case VoiceState.processing:
        return 'Verifying Speaker...';
      case VoiceState.commandRecognized:
        return '"$_lockCommand" Recognized';
    }
  }

  Color _getStatusColor() {
    switch (_currentState) {
      case VoiceState.idle:
        return Colors.white54;
      case VoiceState.disabled:
        return Colors.redAccent;
      case VoiceState.listening:
        return Colors.blueAccent;
      case VoiceState.voiceDetected:
        return Colors.purpleAccent;
      case VoiceState.processing:
        return Colors.orangeAccent;
      case VoiceState.commandRecognized:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Voice Screen App',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => _loadCustomCommand());
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0.2),
                radius: 1.5,
                colors: [Color(0xFF1C1C1E), Colors.black],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildSecurityStateDashboard(),
                const Spacer(),
                _buildCenterMic(),
                const SizedBox(height: 40),
                _buildStatusText(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStateDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _isVoiceLockEnabled ? 'Listening securely' : 'Security Disabled',
                  style: GoogleFonts.inter(color: _isVoiceLockEnabled ? Colors.white : Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Last unlocked 2 hours ago', style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterMic() {
    bool isAnimating = _currentState != VoiceState.idle && _currentState != VoiceState.disabled;

    return GestureDetector(
      onTap: _onMicTapped,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ripple
          if (isAnimating)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor().withOpacity(0.1),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.5, 1.5),
              duration: const Duration(seconds: 2),
            ).fadeOut(duration: const Duration(seconds: 2)),
            
          // Inner glow
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor().withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.3),
                  blurRadius: isAnimating ? 40 : 20,
                  spreadRadius: isAnimating ? 10 : 0,
                )
              ]
            ),
          ).animate(target: isAnimating ? 1 : 0)
           .scale(end: const Offset(1.2, 1.2), duration: const Duration(milliseconds: 500), curve: Curves.easeInOut)
           .then()
           .shimmer(duration: const Duration(seconds: 1)),
           
          // Mic Button
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(),
                  _getStatusColor().withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              _currentState == VoiceState.disabled ? Icons.mic_off_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 40,
            ),
          ).animate(target: isAnimating ? 1 : 0)
           .scaleXY(end: 1.1, duration: const Duration(milliseconds: 300)),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    return Text(
      _getStatusText(),
      style: GoogleFonts.inter(
        color: _getStatusColor(),
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ).animate(key: ValueKey(_currentState))
     .fadeIn(duration: const Duration(milliseconds: 300))
     .slideY(begin: 0.2, end: 0);
  }
}
