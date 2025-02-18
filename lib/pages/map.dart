import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapboxMap mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        styleUri: 'mapbox://styles/mapbox/streets-v12',
        cameraOptions: CameraOptions(
          center: Point(coordinates: Position(4.8357, 45.7640)),
          zoom: 2,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    mapboxMap = map;
    pointAnnotationManager = await map.annotations.createPointAnnotationManager();

    try {
      final ByteData bytes = await rootBundle.load('assets/mark.png');
      final Uint8List imageData = bytes.buffer.asUint8List();

      PointAnnotationOptions options = PointAnnotationOptions(
        geometry: Point(coordinates: Position(4.8357, 45.7640)),
        image: imageData,
        iconSize: 0.2,
      );

      await pointAnnotationManager?.create(options);
    } catch (e) {
      debugPrint("Error loading image: $e");
    }
  }
}
