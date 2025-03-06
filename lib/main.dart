import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home.dart';
import 'pages/map.dart';
import 'pages/login.dart';
import 'pages/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/friend_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 1;
  String? _userId;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((event) {
      setState(() {
        _userId = event.session?.user.id;
      });
    });
  }

  final List<Widget> _pages = [
    const MapPage(),
    HomeApp(),
    ProfilePage(),
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
      home: _userId == null
          ? const LoginPage()
          : Scaffold(
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
              body: _pages[_selectedIndex],
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
                unselectedItemColor: Colors.white.withOpacity(0.6),
                selectedIconTheme: const IconThemeData(color: Colors.white),
                unselectedIconTheme: const IconThemeData(color: Colors.white54),
                selectedLabelStyle: const TextStyle(color: Colors.white),
                unselectedLabelStyle: const TextStyle(color: Colors.black),
                onTap: _onItemTapped,
              ),
            ),
    );
  }
}
