import 'package:flutter/material.dart';

import '../services/google_auth.dart';

class ProfilePage extends StatelessWidget {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  String? _userId;
  ProfilePage({super.key, String? userId}) {
    _userId = userId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 18, 18, 18),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_userId ?? 'Not signed in'),
            ElevatedButton(
                onPressed: () async {
                  if (_userId == null) {
                    await _googleAuthService.signInWithGoogle();
                  } else {
                    await _googleAuthService.signOut();
                    _userId = null;
                  }
                },
                child: Text(_userId == null ? "Sign in with Google" : "Sign out")),
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://picsum.photos/200'),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 8),
            const Text('johndoe@example.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  ProfileTile(icon: Icons.location_on, text: 'Lyon, France'),
                  ProfileTile(icon: Icons.phone, text: '+33 6 12 34 56 78'),
                  ProfileTile(icon: Icons.cake, text: 'Born: January 1, 1990'),
                  ProfileTile(icon: Icons.settings, text: 'Settings'),
                  ProfileTile(icon: Icons.logout, text: 'Log Out'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const ProfileTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
