import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:geolocator/geolocator.dart' as geo;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late mp.MapboxMap mapboxMap;
  mp.PointAnnotationManager? pointAnnotationManager;
  geo.Position? userPosition;

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

    try {
      final ByteData bytes = await rootBundle.load('assets/mark.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      mp.PointAnnotationOptions options = mp.PointAnnotationOptions(
        geometry: mp.Point(coordinates: mp.Position(4.8357, 45.7640)),
        image: imageData,
        iconSize: 0.2,
      );

      await pointAnnotationManager?.create(options);
    } catch (e) {
      debugPrint("Error loading image: $e");
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
