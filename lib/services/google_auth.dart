import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  final supabase = Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    const webClientId = '892122263088-s6rr0qlfeisuukvtcfv9frl5ir33vusi.apps.googleusercontent.com';
    const iosClientId = '892122263088-mjo6pk4sfokfi10edea5rq0s7fpj0ihd.apps.googleusercontent.com';

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
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}