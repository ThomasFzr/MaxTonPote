import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // Your location (Replace with actual dynamic location data)
  final double myLatitude = 37.7749; // Example: San Francisco, CA
  final double myLongitude = -122.4194;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final List<dynamic> response =
          await _supabaseClient.from('users').select();

      List<dynamic> usersWithDistance = response.map((user) {
        double userLat = user['latitude'] ?? 0.0;
        double userLon = user['longitude'] ?? 0.0;
        double distance =
            _calculateDistance(myLatitude, myLongitude, userLat, userLon);

        return {
          ...user,
          'distance': distance, // Add calculated distance
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

  // Haversine formula to calculate distance between two points
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of Earth in km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        backgroundColor: Colors.black,
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
                              '${(user['distance'] ?? 0).toStringAsFixed(1)} km', // Ensure distance is not null
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
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              child: const Text(
                                'Add friend',
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
