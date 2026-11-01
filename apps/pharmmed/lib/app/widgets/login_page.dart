import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Simple login page that only asks for mobile number.
/// Previously required phone/email + password; now simplified to mobile number only.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your mobile number to continue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile number',
                border: OutlineInputBorder(),
                hintText: '+91 98765 12345',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                // Proceed with login
                if (phoneController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logging in...')),
                  );
                  // Navigate back to home (replace current route)
                  GoRouter.of(context).go('/');
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: phoneController.text.isNotEmpty
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged in successfully')),
                      );
                      // Navigate home or to the previous page
                      GoRouter.of(context).go('/');
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}