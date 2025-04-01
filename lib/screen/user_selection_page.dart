import 'package:flutter/material.dart';
import 'package:carwaan/screen/auth_page.dart';

class UserSelectionPage extends StatelessWidget {
  const UserSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView( // ✅ Scrollable to prevent overflow
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth * 0.6; // ✅ Limit to 60% of screen width
                    return Image.asset(
                      'images/Carwaan Logo.png',
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          children: const [
                            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 60),
                            SizedBox(height: 8),
                            Text(
                              "Logo failed to load",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 60),
                _buildSelectionButton(context, 'As Admin', 'admin', Icons.admin_panel_settings),
                _buildSelectionButton(context, 'As Driver', 'driver', Icons.drive_eta),
                _buildSelectionButton(context, 'As Passenger', 'passenger', Icons.person),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(BuildContext context, String text, String role, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuthPage(userRole: role),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(text, style: const TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
