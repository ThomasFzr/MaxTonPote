import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapApp extends StatefulWidget {
  const MapApp({super.key});

  @override
  _MapAppState createState() => _MapAppState();
}

class _MapAppState extends State<MapApp> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? annotationManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        onMapCreated: _onMapCreated,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMarker,
        child: const Icon(Icons.location_pin),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Future<void> _onMapCreated(MapboxMap controller) async {
    mapboxMap = controller;

    // Set the map's access token
    mapboxMap!.loadStyleURI(MapboxStyles.MAPBOX_STREETS);

    // Initialize annotation manager for adding markers
    annotationManager =
        await mapboxMap!.annotations.createPointAnnotationManager();
  }

  Future<void> _addMarker() async {
    if (annotationManager != null) {
      await annotationManager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(2.3522, 48.8566), // Paris
          ),
          textField: "Paris",
          iconSize: 1.5,
        ),
      );
    }
  }
}
