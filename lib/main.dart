import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home.dart';
import 'pages/map.dart';
import 'pages/login.dart';
import 'pages/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
  runApp(const MyApp());
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


  List<Widget> _pages() => [
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
          ? const LoginPage() // Affiche la page de connexion si l'utilisateur n'est pas connecté
          : Scaffold(
              extendBody: true,
              appBar: AppBar(
                title: const Text(
                  'MAX TON POTE',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
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
                selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                selectedIconTheme: const IconThemeData(
                    color: Color.fromARGB(255, 255, 255, 255)),
                unselectedIconTheme: const IconThemeData(
                    color: Color.fromARGB(255, 255, 255, 255)),
                selectedLabelStyle:
                    const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                unselectedLabelStyle:
                    const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                onTap: _onItemTapped,
              ),
            ),
    );
  }
}
