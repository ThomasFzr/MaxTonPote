import 'package:flutter/material.dart';
import '../services/friend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  final FriendService _friendService = FriendService();
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _friendsChannel;

  List<Map<String, dynamic>> _allFriends = [];
  List<Map<String, dynamic>> get allFriends => _allFriends;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  UserProvider() {
    // Charger les données initiales
    fetchUsers();
    // Initialiser la souscription en temps réel
    _initRealtimeSubscription();
  }

  // Method to initialize the real-time subscription for changes in the friends table
  void _initRealtimeSubscription() {
    _friendsChannel?.unsubscribe(); // Unsubscribe from the previous channel if any

    // Create a new subscription to the 'friends' table
    _friendsChannel = _supabase.channel('friends').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'friends',
      callback: (payload) {
        print('Change detected in friends table: ${payload.toString()}');
        fetchUsers(); // Fetch users again after a change is detected
      },
    )..subscribe((status, [error]) {
        print('Subscription status: $status');
        if (error != null) {
          print('Subscription error: $error');
        }
      });
  }

  // Fetch all users that are friends
  Future<void> fetchUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners(); // Notify listeners to indicate loading state

      // Fetch the list of friends from the FriendService
      final result = await _friendService.fetchFriends();
      print('Friends fetched: ${result.length}');

      // Directly use the fetched result (no need for UserModel conversion)
      _allFriends = List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching friends: $e');
      _error = e.toString(); // Capture error for later display
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners to indicate loading is complete
    }
  }

  // Refresh the friends list manually
  Future<void> refreshFriends() async {
    await fetchUsers(); // Simply re-fetch the users
  }

  @override
  void dispose() {
    _friendsChannel?.unsubscribe(); // Unsubscribe from the channel when disposed
    super.dispose();
  }
}
