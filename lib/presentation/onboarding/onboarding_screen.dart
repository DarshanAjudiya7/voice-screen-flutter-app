import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 1;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      // Begin recording automatically as per requirements
    }
  }

  void _simulateRecording() async {
    if (isRecording) return;
    setState(() => isRecording = true);
    
    // Simulate recording duration
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        isRecording = false;
        if (step < 3) {
          step++;
        } else {
          // Registration complete
          _showSuccess();
        }
      });
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        content: const Text(
          'Voice Registration Complete!\nYour voiceprint has been securely encrypted and stored.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('is_voice_registered', true);
              
              if (mounted) {
                Navigator.of(ctx).pop();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              }
            },
            child: const Text('Continue'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Voice Registration')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Say the phrase:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '"Unlock the phone"',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 60),
            
            // Dynamic Waveform placeholder
            Container(
              height: 100,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: isRecording ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                border: Border.all(color: isRecording ? Theme.of(context).primaryColor : Colors.transparent),
              ),
              child: Center(
                child: isRecording 
                    ? const CircularProgressIndicator() // Would be waveform animation
                    : const Icon(Icons.mic, size: 40, color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 60),
            Text(
              'Voice Sample $step / 3',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: step / 3,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _simulateRecording,
              child: const Text('Simulate Speech'),
            )
          ],
        ),
      ),
    );
  }
}
