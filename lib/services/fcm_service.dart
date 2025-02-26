import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await getFCMToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  void listenForTokenChanges(String userId) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      saveTokenToDatabase(userId);
    });
  }
}
