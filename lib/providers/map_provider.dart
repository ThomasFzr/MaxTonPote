import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class MapProvider with ChangeNotifier {
  geo.Position? userPosition;
  List<Map<String, dynamic>> friends = [];
  mp.PointAnnotationManager? pointAnnotationManager;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> fetchUserPosition() async {
    bool isLocationEnabled = await geo.Geolocator.isLocationServiceEnabled();
    geo.LocationPermission permission = await geo.Geolocator.checkPermission();

    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.deniedForever) {
        return;
      }
    }

    if (!isLocationEnabled) {
      return;
    }

    userPosition = await geo.Geolocator.getCurrentPosition();
    notifyListeners();
  }

  Future<void> fetchFriends() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    try {
      final List<dynamic> friendList = await _supabaseClient
          .from('friendship')
          .select('friend_id_1, friend_id_2')
          .or('friend_id_1.eq.${user.id}, friend_id_2.eq.${user.id}');

      final Set<String> friendIds = friendList
          .expand((friend) => [friend['friend_id_1'], friend['friend_id_2']])
          .where((id) => id != user.id)
          .map((id) => id.toString())
          .toSet();

      if (friendIds.isEmpty) return;

      final List<dynamic> response = await _supabaseClient
          .from('users')
          .select()
          .filter('id', 'in', '(${friendIds.join(",")})');

      friends = response.map((friend) {
        return {
          "id": friend['id'],
          "latitude": friend['latitude'] ?? 0.0,
          "longitude": friend['longitude'] ?? 0.0,
          "avatar_url": friend['avatar_url'] ?? 'https://picsum.photos/100/100'
        };
      }).toList();

      notifyListeners();
    } catch (error) {
      debugPrint("Error fetching friends: $error");
    }
  }

  Future<void> addFriendMarkers(mp.MapboxMap map) async {
    pointAnnotationManager = await map.annotations.createPointAnnotationManager();

    for (var friend in friends) {
      await _addFriendMarker(friend["latitude"], friend["longitude"], friend["avatar_url"]);
    }
  }

  Future<void> _addFriendMarker(double lat, double lon, String avatarUrl) async {
    try {
      final ByteData bytes = await rootBundle.load('assets/mark.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      mp.PointAnnotationOptions options = mp.PointAnnotationOptions(
        geometry: mp.Point(coordinates: mp.Position(lon, lat)),
        image: imageData,
        iconSize: 0.2,
      );

      await pointAnnotationManager?.create(options);
    } catch (e) {
      debugPrint("Error adding friend marker: $e");
    }
  }

  mp.MapboxMap? _map;

void setMap(mp.MapboxMap map) {
  _map = map;
}

Future<void> recenterCamera() async {
  if (_map != null && userPosition != null) {
    _map!.flyTo(
      mp.CameraOptions(
        center: mp.Point(coordinates: mp.Position(userPosition!.longitude, userPosition!.latitude)),
        zoom: 14,
      ),
      mp.MapAnimationOptions(),
    );
  } else {
    debugPrint("Map or user position is not available.");
  }
}

}

