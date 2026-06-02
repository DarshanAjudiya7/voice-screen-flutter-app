import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/terms_screen.dart';
import 'background_service_settings_screen.dart';
import 'battery_optimization_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Master Toggle
  bool _isVoiceLockEnabled = true;

  // Custom Commands
  String _lockCommand = 'Lock the phone';
  String _unlockCommand = 'Unlock the phone';
  
  // Sensitivity
  double _sensitivityPercent = 85.0; // Stored as 0.0 to 100.0

  // Backup Auth
  String _activeBackupMethod = 'None';
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVoiceLockEnabled = prefs.getBool('is_voice_lock_enabled') ?? true;
      _lockCommand = prefs.getString('lock_command') ?? 'Lock the phone';
      _unlockCommand = prefs.getString('unlock_command') ?? 'Unlock the phone';
      _sensitivityPercent = prefs.getDouble('sensitivity_percent') ?? 85.0;
      _activeBackupMethod = prefs.getString('active_backup_method') ?? 'None';
    });
  }

  Future<void> _saveSetting<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  Future<void> _toggleMasterLock(bool val) async {
    if (!val) {
      // Prompt confirmation before turning OFF
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text('Disable Voice Lock?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Disabling Voice Screen Lock will stop all voice-based lock and unlock functionality. Do you want to continue?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue', style: TextStyle(color: Colors.redAccent))),
          ],
        ),
      );
      if (confirm != true) return;
    }
    
    setState(() => _isVoiceLockEnabled = val);
    await _saveSetting('is_voice_lock_enabled', val);
  }

  String _getSensitivityLabel() {
    if (_sensitivityPercent < 60) return "Low Security";
    if (_sensitivityPercent < 80) return "Medium Security";
    if (_sensitivityPercent < 90) return "High Security";
    return "Very High Security";
  }

  Color _getSensitivityColor() {
    if (_sensitivityPercent < 60) return Colors.orangeAccent;
    if (_sensitivityPercent < 80) return Colors.yellowAccent;
    if (_sensitivityPercent < 90) return Colors.greenAccent;
    return Colors.blueAccent;
  }

  void _deleteProfile() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Delete Voice Profile?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete your registered voice profile? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_voice_registered');
    await prefs.remove('lock_command');
    await prefs.remove('unlock_command');
    
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 60),
        content: const Text('Voice Profile Deleted Successfully', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (route) => false,
              );
            },
            child: const Text('Continue'),
          )
        ],
      ),
    );
  }

  Future<void> _editCommand(bool isLockCommand) async {
    final TextEditingController controller = TextEditingController(text: isLockCommand ? _lockCommand : _unlockCommand);
    final String title = isLockCommand ? 'Edit Lock Command' : 'Edit Unlock Command';
    
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new command',
            hintStyle: const TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final newCmd = controller.text.trim();
              if (newCmd.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Command cannot be empty')));
                return;
              }
              if (isLockCommand && newCmd.toLowerCase() == _unlockCommand.toLowerCase()) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Lock and Unlock commands must be different.')));
                return;
              }
              if (!isLockCommand && newCmd.toLowerCase() == _lockCommand.toLowerCase()) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Lock and Unlock commands must be different.')));
                return;
              }
              Navigator.pop(ctx, newCmd);
            },
            child: const Text('Save', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (isLockCommand) {
          _lockCommand = result;
          _saveSetting('lock_command', result);
        } else {
          _unlockCommand = result;
          _saveSetting('unlock_command', result);
        }
      });
    }
  }

  Future<void> _changeBackupMethod(String? newMethod) async {
    if (newMethod == null || newMethod == _activeBackupMethod) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Change Backup Method?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Activate $newMethod and disable the current method?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _activeBackupMethod = newMethod;
        _saveSetting('active_backup_method', newMethod);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Settings', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                // 1. Voice Screen Lock Master Toggle
                _buildCardGroup([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Voice Screen Lock', style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_isVoiceLockEnabled ? 'Active' : 'Disabled', style: GoogleFonts.inter(color: _isVoiceLockEnabled ? Colors.greenAccent : Colors.white54, fontSize: 13)),
                          ],
                        ),
                        CupertinoSwitch(
                          activeColor: Colors.greenAccent,
                          value: _isVoiceLockEnabled,
                          onChanged: _toggleMasterLock,
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // 2. Voice Registration
                _buildSectionHeader('Voice Profile'),
                _buildCardGroup([
                  _buildListTile(
                    title: 'Re-register Voice',
                    icon: Icons.refresh_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen())),
                  ),
                ]),
                const SizedBox(height: 24),

                // 3 & 4. Custom Commands
                _buildSectionHeader('Custom Voice Commands'),
                _buildCardGroup([
                  ListTile(
                    title: Text('Lock Command', style: GoogleFonts.inter(color: Colors.white)),
                    subtitle: Text('Current: "$_lockCommand"', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                    trailing: TextButton(onPressed: () => _editCommand(true), child: const Text('Edit')),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    title: Text('Unlock Command', style: GoogleFonts.inter(color: Colors.white)),
                    subtitle: Text('Current: "$_unlockCommand"', style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                    trailing: TextButton(onPressed: () => _editCommand(false), child: const Text('Edit')),
                  ),
                ]),
                const SizedBox(height: 24),

                // 5. Voice Match Sensitivity
                _buildSectionHeader('Voice Match Sensitivity'),
                _buildCardGroup([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sensitivity: ${_sensitivityPercent.toInt()}%', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(_getSensitivityLabel(), style: GoogleFonts.inter(color: _getSensitivityColor(), fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: _sensitivityPercent,
                          min: 0,
                          max: 100,
                          activeColor: _getSensitivityColor(),
                          inactiveColor: Colors.white10,
                          onChanged: (val) {
                            setState(() => _sensitivityPercent = val);
                          },
                          onChangeEnd: (val) {
                            _saveSetting('sensitivity_percent', val);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Higher percentages provide stronger security but may make voice recognition more strict.',
                            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, height: 1.5),
                          ),
                        )
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // 6. Backup Security Method
                _buildSectionHeader('Backup Security Method'),
                _buildCardGroup([
                  RadioListTile<String>(
                    title: Text('PIN', style: GoogleFonts.inter(color: Colors.white)),
                    value: 'PIN',
                    groupValue: _activeBackupMethod,
                    onChanged: _changeBackupMethod,
                    activeColor: Colors.blueAccent,
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  RadioListTile<String>(
                    title: Text('Pattern', style: GoogleFonts.inter(color: Colors.white)),
                    value: 'Pattern',
                    groupValue: _activeBackupMethod,
                    onChanged: _changeBackupMethod,
                    activeColor: Colors.blueAccent,
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  RadioListTile<String>(
                    title: Text('Password', style: GoogleFonts.inter(color: Colors.white)),
                    value: 'Password',
                    groupValue: _activeBackupMethod,
                    onChanged: _changeBackupMethod,
                    activeColor: Colors.blueAccent,
                  ),
                ]),
                const SizedBox(height: 24),

                // 7. Background Service Settings
                // 8. Battery Optimization Settings
                _buildSectionHeader('System Configuration'),
                _buildCardGroup([
                  _buildListTile(
                    title: 'Background Service Settings',
                    icon: Icons.settings_applications_outlined,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackgroundServiceSettingsScreen())),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _buildListTile(
                    title: 'Battery Optimization Settings',
                    icon: Icons.battery_charging_full_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BatteryOptimizationSettingsScreen())),
                  ),
                ]),
                const SizedBox(height: 24),

                // 9. Privacy Policy
                // 10. Terms & Conditions
                _buildSectionHeader('Legal & Privacy'),
                _buildCardGroup([
                  _buildListTile(title: 'Privacy Policy', icon: Icons.privacy_tip_outlined, onTap: () {}),
                  const Divider(color: Colors.white10, height: 1),
                  _buildListTile(
                    title: 'Terms & Conditions', 
                    icon: Icons.description_outlined, 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen())),
                  ),
                ]),
                const SizedBox(height: 40),

                // 11. Delete Voice Profile
                _buildCardGroup([
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    title: Text('Delete Voice Profile', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                    onTap: _deleteProfile,
                  ),
                ]),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildListTile({required String title, required IconData icon, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54),
      title: Text(title, style: GoogleFonts.inter(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }
}
