import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _routeToHome();
  }
  
  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }

  Future<void> _routeToHome() async {
    // Exactly 5 seconds as requested previously
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background as per reference
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Waveform
            AnimatedBuilder(
              animation: _waveformController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(15, (index) {
                    // Create a wave effect by offsetting the animation phase for each bar
                    final double phase = index * 0.5;
                    final double waveHeight = sin((_waveformController.value * pi * 2) + phase);
                    // Base height + wave variation
                    final double barHeight = 20 + (waveHeight.abs() * 40);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9C27B0), // Purple color matching reference
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                );
              },
            ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
            
            const SizedBox(height: 40),
            
            // Animated Text
            Text(
              'Voice Screen',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF9C27B0),
                letterSpacing: 1.2,
              ),
            )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 500), duration: const Duration(milliseconds: 800))
            .slideY(begin: 0.2, end: 0, delay: const Duration(milliseconds: 500)),
          ],
        ),
      ),
    );
  }
}
