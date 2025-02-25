import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:math';

class Person {
  String id;
  String name;
  String imageUrl;
  int distance;

  Person(this.id, this.name, this.imageUrl, this.distance);
}

class FriendProvider extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final Random random = Random();
  List<Person> _friends = [];
  bool _isLoading = true;

  List<Person> get friends => _friends;
  bool get isLoading => _isLoading;

  FriendProvider() {
    fetchFriends();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Rayon de la Terre en km
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<void> fetchFriends() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
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
        _friends = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<dynamic> response = await _supabaseClient
          .from('users')
          .select()
          .filter('id', 'in', '(${friendIds.join(",")})');

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
      notifyListeners();
    } catch (error) {
      print('Error fetching friends: $error');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshFriends() async {
    _isLoading = true;
    notifyListeners();
    await fetchFriends();
  }

  Future<void> removeFriend(String friendId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    try {
      await _supabaseClient.from('friendship').delete().or(
          'and(friend_id_1.eq.${user.id}, friend_id_2.eq.${friendId}), and(friend_id_1.eq.${friendId}, friend_id_2.eq.${user.id})');

      _friends.removeWhere((friend) => friend.id == friendId);
      notifyListeners();
    } catch (error) {
      print("Error deleting friend: $error");
    }
  }
}
