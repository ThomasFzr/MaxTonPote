import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../services/google_auth.dart';

class ProfilePage extends StatelessWidget {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final String? _userId;
  final user = Supabase.instance.client.auth.currentUser;

  ProfilePage({super.key, required String? userId}) : _userId = userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_userId == null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _googleAuthService.signInWithGoogle();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Sign in with Google"),
                    ),
                  ),
                ),
              )
            else ...[
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(user?.userMetadata?['avatar_url']),
              ),
              const SizedBox(height: 16),
              Text(
                user?.userMetadata?['name'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.userMetadata?['email'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    const ProfileTile(icon: Icons.settings, text: 'Settings'),
                    ProfileTile(
                      icon: Icons.logout,
                      text: 'Log Out',
                      onTap: () async {
                        await _googleAuthService.signOut();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const ProfileTile(
      {super.key, required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
