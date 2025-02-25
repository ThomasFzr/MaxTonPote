import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_friend.dart';
import '../services/google_auth.dart';
import '../providers/friend_provider.dart';

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
  final String? userId;

  const HomePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: userId == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: ElevatedButton(
                  onPressed: () async {
                    await GoogleAuthService().signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Sign in with Google"),
                ),
              ),
            )
          : Consumer<FriendProvider>(
              builder: (context, friendProvider, child) {
                if (friendProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (friendProvider.friends.isEmpty) {
                  return const Center(
                    child: Text(
                      'No friends found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      itemCount: friendProvider.friends.length,
                      itemBuilder: (context, index) {
                        final friend = friendProvider.friends[index];
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
                                friend.imageUrl,
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
                              '${friend.distance} km',
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
                            friendProvider.fetchFriends(); // Recharger la liste des amis
                          }
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                  ],
                );
              },
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
                '${person.distance} km away',
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
                    'DEMANDER UN MESSAGE',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) return;

                    try {
                      await Supabase.instance.client
                          .from('friendship')
                          .delete()
                          .or('and(friend_id_1.eq.${user.id}, friend_id_2.eq.${person.id}), and(friend_id_1.eq.${person.id}, friend_id_2.eq.${user.id})');

                      Provider.of<FriendProvider>(context, listen: false)
                          .fetchFriends();

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Friend removed successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (error) {
                      print("Error deleting friend: $error");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 106, 0, 0),
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
