import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:math';

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  List<dynamic> _users = [];
  bool _isLoading = true;
  final Random random = Random();
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print("No logged-in user.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final position = await geo.Geolocator.getCurrentPosition();

    try {
      final List<dynamic> friendList = await _supabaseClient
          .from('friendship')
          .select('friend_id_1, friend_id_2')
          .or('friend_id_1.eq.${user.id}, friend_id_2.eq.${user.id}');

      final Set<String> friendIds = friendList
          .expand((friend) => [friend['friend_id_1'], friend['friend_id_2']])
          .map((id) => id.toString())
          .toSet();

      final List<dynamic> response =
          await _supabaseClient.from('users').select().neq('id', user.id);

      List<dynamic> usersWithDistance =
          response.where((u) => !friendIds.contains(u['id'])).map((user) {
        double userLat = user['latitude'] ?? 0.0;
        double userLon = user['longitude'] ?? 0.0;
        double distance = _calculateDistance(
            position.latitude, position.longitude, userLat, userLon);

        return {
          ...user,
          'distance': distance,
        };
      }).toList();

      setState(() {
        _users = usersWithDistance;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching users: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addFriend(String friendId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await _supabaseClient.from('friendship').insert({
        'friend_id_1': user.id,
        'friend_id_2': friendId,
      });

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

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(
                  child: Text('No users found',
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
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
