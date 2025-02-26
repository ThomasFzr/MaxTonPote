import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home.dart';
import 'pages/map.dart';
import 'pages/profile.dart';

// Background notification handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Load environment variables
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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) async {
      setState(() {
        _userId = data.session?.user.id;
      });
      if (_userId != null) {
        _setupFCM();
      }
    });
  }

  Future<void> _setupFCM() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      print("🔥 FCM Token: $token");
      if (token != null) {
        await _saveTokenToDatabase(token);
      }
    }
    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _saveTokenToDatabase(newToken);
    });
  }

  Future<void> _saveTokenToDatabase(String token) async {
    if (_userId == null) return;
    await supabase.from('users').update({
      'fcm_token': token,
    }).eq('id', _userId!);
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
          backgroundColor: Colors.black,
        ),
        body: _pages()[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black,
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
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
