import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_friend.dart';
import '../services/google_auth.dart';

class Person {
  String name;
  String imageUrl;
  int distance;

  Person(this.name, this.imageUrl, this.distance);
}

class HomeApp extends StatelessWidget {
  final String? _userId;

  const HomeApp({super.key, required String? userId}) : _userId = userId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userId: _userId),
    );
  }
}

class HomePage extends StatelessWidget {
  final String? _userId;
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final user = Supabase.instance.client.auth.currentUser;
  final List<String> names = [
    'Alice',
    'Bob',
    'Charlie',
    'David',
    'Emma',
    'Frank',
    'Grace',
    'Henry',
    'Isabella',
    'Jack',
    'Katie',
    'Leo',
    'Mia',
    'Nathan',
    'Olivia',
    'Paul',
    'Quincy',
    'Rachel',
    'Samuel',
    'Tina'
  ];

  final Random random = Random();

  HomePage({super.key, required String? userId}) : _userId = userId;

  @override
  Widget build(BuildContext context) {
    List<Person> persons = List.generate(
      20,
      (index) => Person(
        names[index],
        'https://picsum.photos/seed/${random.nextInt(1000)}/100/100',
        random.nextInt(50) + 1,
      ),
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: Stack(
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
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 80.0), // Add padding at the bottom
              child: ListView.builder(
                itemCount: persons.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 6.0,
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          persons[index].imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        persons[index].name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        '${persons[index].distance} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _showUserModal(context, persons[index]),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 110,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFriendPage()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _showUserModal(BuildContext context, Person person) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  person.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 20,
                width: 400,
              ),
              Text(
                person.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${person.distance} km away',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  debugPrint('${person.name} button clicked!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text(
                  'DEMANDER UN MAXAGE',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
