import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BackupAuthScreen extends StatelessWidget {
  final String authType; // 'PIN', 'Pattern', or 'Password'

  const BackupAuthScreen({super.key, required this.authType});

  void _simulateUnlock(BuildContext context) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      Navigator.of(context).pop(); // remove dialog
      
      // Navigate back to the home screen by popping until home
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Unlock with $authType',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              authType == 'PIN' ? Icons.dialpad_rounded : 
              authType == 'Pattern' ? Icons.pattern_rounded : Icons.password_rounded,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 32),
            Text(
              'Enter your $authType',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'This is a backup authentication method.',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 60),
            
            // Dummy input field area
            Container(
              width: 250,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Center(
                child: Text('***', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _simulateUnlock(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Simulate Unlock',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
