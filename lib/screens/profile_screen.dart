import 'package:flutter/material.dart';
import '../models/user.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.green[50];
    final cardColor = isDark ? Colors.grey[800] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Icon
            CircleAvatar(
              radius: 50,
              backgroundColor: isDark ? Colors.green[700] : Colors.green[200],
              child: Icon(Icons.person, size: 50, color: isDark ? Colors.black : Colors.white),
            ),
            const SizedBox(height: 20),
            // User Email Card
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: Icon(Icons.email, color: isDark ? Colors.green[300] : Colors.green[700]),
                title: Text("Email", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                subtitle: Text(user.email, style: TextStyle(color: textColor)),
              ),
            ),
            const SizedBox(height: 15),
            // User ID Card
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: Icon(Icons.badge, color: isDark ? Colors.green[300] : Colors.green[700]),
                title: Text("User ID", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                subtitle: Text(user.id?.toString() ?? "N/A", style: TextStyle(color: textColor)),
              ),
            ),
            const SizedBox(height: 30),
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.green[700] : Colors.green[600],
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}