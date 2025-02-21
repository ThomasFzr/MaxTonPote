import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    if (googleUser == null) {
      return;
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      return;
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final user = supabase.auth.currentUser;
    if (user != null) {
      final position = await geo.Geolocator.getCurrentPosition();

      final userExist = await supabase
          .from("users")
          .select()
          .eq("id", user.id)
          .maybeSingle();

      if (userExist == null) {
        await supabase.from('users').upsert({
          'email': user.email,
          'name': user.userMetadata?['name'] ?? '',
          'avatar_url': user.userMetadata?['picture'] ?? '',
          'latitude': position.latitude,
          'longitude': position.longitude,
          'is_logged': true,
        });
      } else{
        await supabase.from('users').update({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'is_logged': true,
        }).eq('id', user.id);
      }
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
