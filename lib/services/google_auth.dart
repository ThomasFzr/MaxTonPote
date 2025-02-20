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
          .from("user")
          .select()
          .eq("google_id", user.id)
          .maybeSingle();

      if (userExist == null) {
        await supabase.from('user').upsert({
          'email': user.email,
          'fullname': user.userMetadata?['name'] ?? '',
          'avatar_url': user.userMetadata?['picture'] ?? '',
          'latitude': position.latitude,
          'longitude': position.longitude,
          'google_id': googleUser.id,
          'is_logged': true,
        });
      }
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
