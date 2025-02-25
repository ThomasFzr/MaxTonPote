import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'add_friend.dart';
import '../services/google_auth.dart';

class Person {
  String id;
  String name;
  String imageUrl;
  int distance;

  Person(this.id, this.name, this.imageUrl, this.distance);
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

class HomePage extends StatefulWidget {
  final String? userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  List<Person> _friends = [];
  bool _isLoading = true;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    _supabaseClient.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session?.user != null) {
        _fetchFriends();
      } else {
        setState(() {
          _friends = [];
          _isLoading = false;
        });
      }
    });

    _fetchFriends();
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

  Future<void> _fetchFriends() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final position = await geo.Geolocator.getCurrentPosition();

      final List<dynamic> friendList = await _supabaseClient
          .from('friendship')
          .select('friend_id_1, friend_id_2')
          .or('friend_id_1.eq.${user.id}, friend_id_2.eq.${user.id}');

      final Set<String> friendIds = friendList
          .expand((friend) => [friend['friend_id_1'], friend['friend_id_2']])
          .where((id) => id != user.id)
          .map((id) => id.toString())
          .toSet();

      if (friendIds.isEmpty) {
        setState(() {
          _friends = [];
          _isLoading = false;
        });
        return;
      }

      final List<dynamic> response = await _supabaseClient
          .from('users')
          .select()
          .filter('id', 'in', '(${friendIds.join(",")})');

      setState(() {
        _friends = response.map((friend) {
          double friendLat = friend['latitude'] ?? 0.0;
          double friendLon = friend['longitude'] ?? 0.0;
          double distance = _calculateDistance(
              position.latitude, position.longitude, friendLat, friendLon);

          return Person(
            friend['id'],
            friend['name'] ?? 'Unknown',
            friend['avatar_url'] ??
                'https://picsum.photos/seed/${random.nextInt(1000)}/100/100',
            distance.toInt(),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching friends: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: widget.userId == null
          ? Center(
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
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    _friends.isEmpty
                        ? const Center(
                            child: Text(
                              'No friends found',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _friends.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: 6.0,
                                  left: 6.0,
                                  right: 6.0,
                                  bottom:
                                      index == _friends.length - 1 ? 80.0 : 6.0,
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.network(
                                      _friends[index].imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    _friends[index].name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Text(
                                    '${_friends[index].distance} km',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () =>
                                      _showUserModal(context, _friends[index]),
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
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
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
                    final user = _supabaseClient.auth.currentUser;
                    if (user == null) return;

                    try {
                      await _supabaseClient.from('friendship').delete().or(
                          'and(friend_id_1.eq.${user.id}, friend_id_2.eq.${person.id}), and(friend_id_1.eq.${person.id}, friend_id_2.eq.${user.id})');

                      setState(() {
                        _friends
                            .removeWhere((friend) => friend.id == person.id);
                      });

                      Navigator.pop(context);
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
