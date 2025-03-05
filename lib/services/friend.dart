import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:math';

class FriendService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<dynamic>> fetchUsers() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      print("No logged-in user.");
      return [];
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

      return response.where((u) => !friendIds.contains(u['id'])).map((user) {
        double userLat = user['latitude'] ?? 0.0;
        double userLon = user['longitude'] ?? 0.0;
        double distance = _calculateDistance(
            position.latitude, position.longitude, userLat, userLon);

        return {
          ...user,
          'distance': distance,
        };
      }).toList();
    } catch (error) {
      print('Error fetching users: $error');
      return [];
    }
  }

  Future<void> addFriend(String friendId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    try {
      await _supabaseClient.from('friendship').insert({
        'friend_id_1': user.id,
        'friend_id_2': friendId,
      });
    } catch (error) {
      print('Error adding friend: $error');
      throw error;
    }
  }

  Future<void> deleteFriend(String friendId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated");
    }

    try {
      await _supabaseClient.from('friendship').delete().or(
          'and(friend_id_1.eq.${user.id}, friend_id_2.eq.${friendId}), and(friend_id_1.eq.${friendId}, friend_id_2.eq.${user.id})');
    } catch (error) {
      print("Error deleting friend: $error");
      throw Exception("Error deleting friend");
    }
  }

  // Method to fetch friends of the logged-in user
  Future<List<dynamic>> fetchFriends() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      print("No logged-in user.");
      return [];
    }

    final position = await geo.Geolocator.getCurrentPosition();

    try {
      // Fetch the friendship records for the logged-in user
      final List<dynamic> friendList = await _supabaseClient
          .from('friendship')
          .select('friend_id_1, friend_id_2')
          .or('friend_id_1.eq.${user.id}, friend_id_2.eq.${user.id}');

      final Set<String> friendIds = friendList
          .expand((friend) => [friend['friend_id_1'], friend['friend_id_2']])
          .where((id) => id != user.id)  // Exclude the logged-in user
          .map((id) => id.toString())
          .toSet();

      // Fetch the user details for the friends
      if (friendIds.isEmpty) {
        return [];
      }

      final List<dynamic> friends = await _supabaseClient
          .from('users')
          .select()
          .filter('id', 'in', '(${friendIds.join(",")})');

      // Calculate the distance for each friend
      return friends.map((friend) {
        double friendLat = (friend['latitude'] ?? 0.0).toDouble();
        double friendLon = (friend['longitude'] ?? 0.0).toDouble();
        double distance = _calculateDistance(
            position.latitude, position.longitude, friendLat, friendLon);

        return {
          ...friend,
          'distance': distance,
        };
      }).toList();
    } catch (error) {
      print('Error fetching friends: $error');
      return [];
    }
  }

  // Method to calculate distance between two geographical coordinates
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the Earth in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in kilometers
  }

  // Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
