import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/home.dart';
import 'pages/map.dart';
import 'pages/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  String accessToken = dotenv.get("SK_MAPBOX_TOKEN");
  MapboxOptions.setAccessToken(accessToken);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const MapPage(),
    const HomeApp(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true, // Allows transparency effect on bottom bar
        appBar: AppBar(
          title: const Text(
            'MAX TON POTE',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 119, 31, 58), // Keep AppBar color
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey, // Transparent BottomNavigationBar
          elevation: 0, // Removes shadow
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 138, 0, 41),
          unselectedItemColor: Colors.white,
          selectedIconTheme: const IconThemeData(color: Color.fromARGB(255, 138, 0, 41)),
          unselectedIconTheme: const IconThemeData(color: Colors.white),
          selectedLabelStyle: const TextStyle(color: Color.fromARGB(255, 119, 31, 58)),
          unselectedLabelStyle: const TextStyle(color: Color.fromARGB(255, 119, 31, 58)),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
