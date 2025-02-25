import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home.dart';
import 'pages/map.dart';
import 'pages/profile.dart';
import 'providers/friend_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  String accessToken = dotenv.get("SK_MAPBOX_TOKEN");
  MapboxOptions.setAccessToken(accessToken);

  String supabaseUrl = dotenv.get("SUPABASE_URL");
  String supabaseKey = dotenv.get("SUPABASE_API_KEY");

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ✅ AJOUTE CE CODE ICI pour éviter l'erreur "MyApp isn't a class"
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 1;
  String? _userId;

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _userId = data.session?.user.id;
      });
    });
  }

  List<Widget> _pages() => [
        const MapPage(),
        HomeApp(userId: _userId),
        ProfilePage(userId: _userId),
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
        extendBody: true,
        appBar: AppBar(
          title: const Text(
            'MAX TON POTE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 18, 18, 18),
        ),
        body: _pages()[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 18, 18, 18),
          elevation: 0,
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
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
