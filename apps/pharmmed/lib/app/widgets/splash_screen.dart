import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash screen shown on first launch.
/// Displays the app name and a welcome quote, then navigates to login after 5 seconds.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to login after a 5-second delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 5), () {
        GoRouter.of(context).go('/login');
      });
    });

    return Scaffold(
      body: Center(
        child: Container(
          color: const Color(0xFF1B5E20), // Primary green background
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App name
              Text(
                'Dawaidukaan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // Tagline
              Text(
                'Care today. Thrive tomorrow.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}