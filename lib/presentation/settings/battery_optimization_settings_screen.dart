import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class BatteryOptimizationSettingsScreen extends StatelessWidget {
  const BatteryOptimizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Battery Optimization', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orangeAccent.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildInfoBanner(),
                const SizedBox(height: 30),
                _buildSectionHeader('Current Status'),
                _buildCardGroup([
                  _buildStatusTile(
                    title: 'Battery Optimization Status',
                    statusText: 'Enabled',
                    statusColor: Colors.orangeAccent,
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _buildStatusTile(
                    title: 'Background Usage Permission',
                    statusText: 'Restricted',
                    statusColor: Colors.orangeAccent,
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _buildStatusTile(
                    title: 'Microphone Background Access',
                    statusText: 'Allowed',
                    statusColor: Colors.greenAccent,
                  ),
                ]),
                const SizedBox(height: 30),
                _buildSectionHeader('Actions'),
                _buildCardGroup([
                  _buildActionTile(
                    title: 'Exclude App From Battery Optimization',
                    icon: Icons.battery_alert_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Simulating native battery optimization exclusion request...')),
                      );
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _buildActionTile(
                    title: 'Open System Battery Settings',
                    icon: Icons.settings_system_daydream_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Simulating opening Android settings intent...')),
                      );
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

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.orangeAccent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'For reliable voice recognition and background listening, battery optimization should be disabled for Voice Screen App.',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.5),
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

  Widget _buildStatusTile({required String title, required String statusText, required Color statusColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Text(
        statusText,
        style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildActionTile({required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: onTap,
    );
  }
}
