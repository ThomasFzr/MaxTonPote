import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:geolocator/geolocator.dart' as geo;
import 'dart:async';
import '../services/friend.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late mp.MapboxMap mapboxMap;
  mp.PointAnnotationManager? pointAnnotationManager;
  geo.Position? userPosition;
  StreamSubscription<geo.Position>? positionStreamSubscription;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  Timer? _pulseTimer;
  Map<String, mp.PointAnnotation> friendMarkers = {};
  final FriendService _friendService = FriendService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pulseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateFriendMarkers();
    });
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    _animationController.dispose();
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mp.MapWidget(
            styleUri: 'mapbox://styles/mapbox/dark-v11',
            cameraOptions: mp.CameraOptions(
              center: mp.Point(coordinates: mp.Position(4.8357, 45.7640)),
              zoom: 14,
            ),
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            bottom: 110,
            right: 20,
            child: FloatingActionButton(
              onPressed: _recenterCamera,
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMapCreated(mp.MapboxMap map) async {
    map.scaleBar.updateSettings(mp.ScaleBarSettings(enabled: false));
    map.logo.updateSettings(mp.LogoSettings(enabled: false));
    map.attribution.updateSettings(mp.AttributionSettings(enabled: false));

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

    geo.Position position = await geo.Geolocator.getCurrentPosition();
    userPosition = position;

    mapboxMap = map;
    pointAnnotationManager = await map.annotations.createPointAnnotationManager();

    map.location.updateSettings(mp.LocationComponentSettings(
      enabled: true,
      pulsingEnabled: true,
      pulsingColor: Colors.blue.value,
    ));

    map.flyTo(mp.CameraOptions(
      center: mp.Point(coordinates: mp.Position(position.longitude, position.latitude)),
      zoom: 14,
    ), mp.MapAnimationOptions());

    await _fetchAndShowFriends();

    positionStreamSubscription = geo.Geolocator.getPositionStream().listen((geo.Position position) {
      userPosition = position;
      mapboxMap.flyTo(mp.CameraOptions(
        center: mp.Point(coordinates: mp.Position(position.longitude, position.latitude)),
        zoom: 14,
      ), mp.MapAnimationOptions());
    });
  }

  Future<void> _fetchAndShowFriends() async {
    List<dynamic> friends = await _friendService.fetchFriends();

    if (friends.isEmpty) return;

    for (var friend in friends) {
      double friendLat = friend['latitude'] ?? 0.0;
      double friendLon = friend['longitude'] ?? 0.0;
      String friendId = friend['id'];
      String avatarUrl = friend['avatar_url'] ?? 'https://picsum.photos/100/100';

      _addFriendMarker(friendId, friendLat, friendLon, avatarUrl);
    }
  }

  Future<void> _addFriendMarker(String friendId, double lat, double lon, String avatarUrl) async {
    try {
      final ByteData bytes = await rootBundle.load('assets/mark.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      mp.PointAnnotationOptions options = mp.PointAnnotationOptions(
        geometry: mp.Point(coordinates: mp.Position(lon, lat)),
        image: imageData,
        iconSize: _pulseAnimation.value,
      );

      mp.PointAnnotation? marker = await pointAnnotationManager?.create(options);
      
      if (marker != null) {
        friendMarkers[friendId] = marker;
      }
    } catch (e) {
      debugPrint("Error adding friend marker: $e");
    }
  }

  void _updateFriendMarkers() {
    for (var marker in friendMarkers.values) {
      marker.iconSize = _pulseAnimation.value;
      pointAnnotationManager?.update(marker);
    }
  }

  Future<void> _recenterCamera() async {
    if (userPosition != null) {
      mapboxMap.flyTo(mp.CameraOptions(
        center: mp.Point(coordinates: mp.Position(userPosition!.longitude, userPosition!.latitude)),
        zoom: 14,
      ), mp.MapAnimationOptions());
    } else {
      debugPrint("User position is not available yet.");
    }
  }
}
