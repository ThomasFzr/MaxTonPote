import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/friend_provider.dart';

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    await friendProvider.fetchUsers();
  }

  Future<void> _addFriend(String friendId) async {
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);
    try {
      await friendProvider.addFriend(friendId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ami ajouté!', style: TextStyle(color: Colors.black)),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      print('Error adding friend: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add friend. Try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendProvider = Provider.of<FriendProvider>(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: friendProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : friendProvider.users.isEmpty
              ? const Center(
                  child: Text('No users found',
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: friendProvider.users.length,
                  itemBuilder: (context, index) {
                    final user = friendProvider.users[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 6.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: user['avatar_url'] != null &&
                                      user['avatar_url'].isNotEmpty
                                  ? Image.network(
                                      user['avatar_url'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.account_circle,
                                            size: 50, color: Colors.grey);
                                      },
                                    )
                                  : const Icon(Icons.account_circle,
                                      size: 50, color: Colors.grey),
                            ),
                            title: Text(
                              user['name'] ?? 'No Username',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Text(
                              '${(user['distance'] ?? 0).toInt()} km',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex =
                                    _selectedIndex == index ? null : index;
                              });
                            },
                          ),
                        ),
                        if (_selectedIndex == index)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ElevatedButton(
                              onPressed: () => _addFriend(user['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              child: const Text(
                                'Ajouter en ami',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
    );
  }
}
