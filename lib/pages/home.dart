import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_friend.dart';
import '../providers/friend_provider.dart';

class Person {
  String id;
  String name;
  String imageUrl;
  double distance;

  Person(this.id, this.name, this.imageUrl, this.distance);
}

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session?.user != null) {
        _fetchFriends();
      }
    });

    _fetchFriends();
  }

  void _fetchFriends() async {
    try {
      final friendProvider =
          Provider.of<FriendProvider>(context, listen: false);
      await friendProvider.fetchFriends();

      print("Fetched friends: ${friendProvider.friends}");
    } catch (error) {
      print("Error fetching friends: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendProvider = context.watch<FriendProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: friendProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                friendProvider.friends.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun ami trouvé',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: friendProvider.friends.length,
                        itemBuilder: (context, index) {
                          final data = friendProvider.friends[index];
                          final friend = Person(
                            data['id'] as String,
                            data['name'] as String,
                            data['avatar_url'] as String? ??
                                'https://via.placeholder.com/100',
                            (data['distance'] as num?)?.toDouble() ?? 0.0,
                          );

                          String imageUrl = (friend.imageUrl.isNotEmpty)
                              ? friend.imageUrl
                              : 'https://picsum.photos/seed/${random.nextInt(1000)}/100/100';

                          return Padding(
                            padding: EdgeInsets.only(
                              top: 6.0,
                              left: 6.0,
                              right: 6.0,
                              bottom: index == friendProvider.friends.length - 1
                                  ? 80.0
                                  : 6.0,
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                friend.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Text(
                                '${friend.distance.toInt()} km',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () => _showUserModal(context, friend),
                            ),
                          );
                        },
                      ),
                Positioned(
                  bottom: 110,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddFriendPage()),
                      );

                      if (result == true) {
                        _fetchFriends();
                      }
                    },
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                ),
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
          padding: const EdgeInsets.fromLTRB(70, 5, 70, 120),
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
              const SizedBox(height: 20),
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
                'à ${person.distance.toInt()} km',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('${person.name} button clicked!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    'DEMANDER UN MAXAGE',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = supabase.auth.currentUser;
                    if (user == null) return;

                    try {
                      await Provider.of<FriendProvider>(context, listen: false)
                          .deleteFriend(person.id);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ami supprimé!',
                            style: TextStyle(color: Colors.black),
                          ),
                          backgroundColor: Color.fromARGB(255, 255, 255, 255),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (error) {
                      print("Error deleting friend: $error");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 189, 4, 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    "SUPPRIMER L'AMI",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
