import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

class GoogleAuthService {
  final supabase = Supabase.instance.client;

 Future<void> signInWithGoogle() async {
  await dotenv.load(fileName: '.env');
  String webClientId = dotenv.get("WEB_CLIENT_ID");
  String iosClientId = dotenv.get("IOS_CLIENT_ID");

  final googleSignIn = GoogleSignIn(
    clientId: iosClientId,
    serverClientId: webClientId,
  );

  final googleUser = await googleSignIn.signIn();
  if (googleUser == null) return;

  final googleAuth = await googleUser.authentication;
  final accessToken = googleAuth.accessToken;
  final idToken = googleAuth.idToken;

  if (accessToken == null || idToken == null) return;

  await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );

  // Attendre que `currentUser` soit mis à jour
  User? user;
  for (int i = 0; i < 10; i++) {
    user = supabase.auth.currentUser;
    if (user != null) break;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  if (user == null) {
    print("Erreur: utilisateur non trouvé après connexion.");
    return;
  }

  // Demander la permission pour recevoir des notifications
  await FirebaseMessaging.instance.requestPermission();

  // Récupérer le FCM token après autorisation
  final fcmToken = await FirebaseMessaging.instance.getToken();

  // Récupérer la position de l'utilisateur
  final position = await geo.Geolocator.getCurrentPosition();

  // Vérifier si l'utilisateur existe déjà en base
  final userExist = await supabase
      .from("users")
      .select()
      .eq("id", user.id)
      .maybeSingle();

  if (userExist == null) {
    // Insérer le nouvel utilisateur avec le FCM token
    await supabase.from('users').upsert({
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['name'] ?? '',
      'avatar_url': user.userMetadata?['picture'] ?? '',
      'latitude': position.latitude,
      'longitude': position.longitude,
      'is_logged': true,
      'fcm_token': fcmToken, // Ajouter ici
    });
  } else {
    // Mettre à jour l'utilisateur existant avec le FCM token
    await supabase.from('users').update({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'is_logged': true,
      'fcm_token': fcmToken, // Ajouter ici
    }).eq('id', user.id);
  }
}

  Future<void> signOut() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase.from('users').update({
        'is_logged': false,
      }).eq('id', user.id);
    }
    await supabase.auth.signOut();
  }
}
