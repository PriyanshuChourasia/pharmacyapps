import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Login screen that only asks for mobile number, displayed without an app bar.
/// Includes a banner with doctor/nurse/staff icons at top, phone input,
/// Get OTP button, horizontal line, and Continue with Google button.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    // Color scheme - pharmacy/healthcare themed
    const Color primaryGreen = Color(0xFF1B5E20);
    const Color secondaryGreen = Color(0xFF2E7D32);
    const Color backgroundColor = Color(0xFFF5F5F5);
    const Color cardColor = Colors.white;
    const Color textPrimary = Color(0xFF212121);
    const Color dividerColor = Color(0xFFB0B0B0);

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            // Top half: Banner with icons and colors
            Container(
              height: MediaQuery.of(context).size.height / 2,
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icons row - Doctor, Nurse, Staff
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.person_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.person_outlined,
                            color: Colors.white,
                            size: 40,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // App name in white
                      const Text(
                        'Dawaidukaan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline in white70
                      const Text(
                        'Care today. Thrive tomorrow.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom half: Phone input, Get OTP, divider, and Google button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                decoration: const BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Phone input field with filled decoration
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Enter phone',
                          hintText: '+91 98765 12345',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryGreen),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryGreen),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: secondaryGreen, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: primaryGreen,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Get OTP button
                      ElevatedButton(
                        onPressed: phoneController.text.isNotEmpty
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text('OTP sent to your phone...')),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Get OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider horizontal line
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: dividerColor,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Continue with Google button
                      ElevatedButton.icon(
                        onPressed: phoneController.text.isNotEmpty
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text('Logging in with Google...')),
                                );
                                // Navigate home
                                GoRouter.of(context).go('/');
                              }
                            : null,
                        icon: const Icon(Icons.gesture, color: Colors.white),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: secondaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}