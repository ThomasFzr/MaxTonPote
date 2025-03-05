// import 'package:flutter/material.dart';
// import '../services/friend.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class UserProvider extends ChangeNotifier {
//   final FriendService _friendService = FriendService();
//   final _supabase = Supabase.instance.client;
//   RealtimeChannel? _friendsChannel;

//   List<UserModel> _allFriends = [];
//   List<UserModel> get allFriends => _allFriends;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String? _error;
//   String? get error => _error;

//   UserProvider() {
//     // Charger les données initiales
//     fetchUsers();
//     // Initialiser la souscription en temps réel
//     _initRealtimeSubscription();
//   }

//   void _initRealtimeSubscription() {
//     _friendsChannel?.unsubscribe();

//     _friendsChannel = _supabase.channel('friends').onPostgresChanges(
//       event: PostgresChangeEvent.all,
//       schema: 'public',
//       table: 'friends',
//       callback: (payload) {
//         print('Changement détecté dans la table friends: ${payload.toString()}');
//         fetchUsers();
//       },
//     )..subscribe((status, [error]) {
//         print('Status de la souscription: $status');
//         if (error != null) {
//           print('Erreur de souscription: $error');
//         }
//       });
//   }

//   Future<void> fetchUsers() async {
//     try {
//       _isLoading = true;
//       _error = null;
//       notifyListeners();

//       final result = await _friendService.fetchFriends();
//       print('Amis récupérés: ${result.length}');
//       _allFriends = result.map((json) => UserModel.fromJson(json)).toList();
//     } catch (e) {
//       print('Erreur lors de la récupération des amis: $e');
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> refreshFriends() async {
//     await fetchUsers();
//   }

//   @override
//   void dispose() {
//     _friendsChannel?.unsubscribe();
//     super.dispose();
//   }
// }