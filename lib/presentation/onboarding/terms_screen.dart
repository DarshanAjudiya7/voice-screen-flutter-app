import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Terms & Conditions', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        child: ListView(
                          children: [
                            _buildTermSection('Voice Data Usage', 'Your voice data is securely processed locally and used exclusively for unlocking your device. No biometric data leaves your phone.'),
                            _buildTermSection('Privacy Policy', 'We do not collect or transmit your voice print to external servers. All biometric data remains encrypted on this device using AES-256.'),
                            _buildTermSection('Microphone Permission Usage', 'This application requires continuous microphone access to securely listen for your custom "Unlock" command when running in the background.'),
                            _buildTermSection('Security Responsibilities', 'Voice recognition is a convenience feature. You are responsible for configuring backup authentication methods (PIN, Pattern, or Password) to prevent getting locked out.'),
                            _buildTermSection('User Responsibilities', 'Do not share your custom lock and unlock phrases with untrusted individuals. Keep your phrases distinct and memorable.'),
                            _buildTermSection('Disclaimer', 'The developers of this app are not responsible for any data loss, device lockouts, or unauthorized access resulting from the use of this software.'),
                            _buildTermSection('Data Storage Information', 'Your voice model and settings are stored locally using encrypted SharedPreferences and secure storage.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: GoogleFonts.inter(color: Colors.white54, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
