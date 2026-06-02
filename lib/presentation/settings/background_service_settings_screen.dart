import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class BackgroundServiceSettingsScreen extends StatefulWidget {
  const BackgroundServiceSettingsScreen({super.key});

  @override
  State<BackgroundServiceSettingsScreen> createState() => _BackgroundServiceSettingsScreenState();
}

class _BackgroundServiceSettingsScreenState extends State<BackgroundServiceSettingsScreen> {
  bool _isContinuousListening = true;
  bool _isBackgroundDetection = true;
  bool _isAutoStart = true;
  bool _isAutoRestart = true;
  bool _isServiceActive = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isContinuousListening = prefs.getBool('continuous_listening') ?? true;
      _isBackgroundDetection = prefs.getBool('background_detection') ?? true;
      _isAutoStart = prefs.getBool('auto_start') ?? true;
      _isAutoRestart = prefs.getBool('auto_restart') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Background Service', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildHealthIndicator(),
                const SizedBox(height: 30),
                _buildSectionHeader('Service Configuration'),
                _buildCardGroup([
                  _buildSwitchTile(
                    title: 'Continuous Voice Listening',
                    subtitle: 'Listen for voice commands even when the screen is off.',
                    value: _isContinuousListening,
                    onChanged: (val) {
                      setState(() => _isContinuousListening = val);
                      _saveSetting('continuous_listening', val);
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _buildSwitchTile(
                    title: 'Background Voice Detection',
                    subtitle: 'Analyze background noise to detect matching commands.',
                    value: _isBackgroundDetection,
                    onChanged: (val) {
                      setState(() => _isBackgroundDetection = val);
                      _saveSetting('background_detection', val);
                    },
                  ),
                ]),
                const SizedBox(height: 30),
                _buildSectionHeader('System Integration'),
                _buildCardGroup([
                  _buildSwitchTile(
                    title: 'Auto Start Service On Boot',
                    subtitle: 'Restart the listening service automatically when device reboots.',
                    value: _isAutoStart,
                    onChanged: (val) {
                      setState(() => _isAutoStart = val);
                      _saveSetting('auto_start', val);
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _buildSwitchTile(
                    title: 'Restart Service Automatically',
                    subtitle: 'If the system kills the app, it will attempt to revive the service.',
                    value: _isAutoRestart,
                    onChanged: (val) {
                      setState(() => _isAutoRestart = val);
                      _saveSetting('auto_restart', val);
                    },
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isServiceActive ? Colors.greenAccent : Colors.redAccent,
              boxShadow: [
                BoxShadow(
                  color: (_isServiceActive ? Colors.greenAccent : Colors.redAccent).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Foreground Service Status', style: GoogleFonts.inter(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  _isServiceActive ? 'Running (Active)' : 'Stopped (Inactive)', 
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
      ),
      value: value,
      activeColor: Colors.blueAccent,
      onChanged: onChanged,
    );
  }
}
