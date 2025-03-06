import 'package:flutter/material.dart';
import '../services/friend_service.dart';

class FriendProvider with ChangeNotifier {
  final FriendService _friendService = FriendService();
  List<dynamic> _users = [];
  List<dynamic> _friends = [];
  bool _isLoading = false;

  List<dynamic> get users => _users;
  List<dynamic> get friends => _friends;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();

    _users = await _friendService.fetchUsers();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFriends() async {
    _isLoading = true;
    notifyListeners();

    _friends = await _friendService.fetchFriends();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFriend(String friendId) async {
    await _friendService.addFriend(friendId);
    fetchFriends();
  }

  Future<void> deleteFriend(String friendId) async {
    await _friendService.deleteFriend(friendId);
    fetchFriends();
  }
}
