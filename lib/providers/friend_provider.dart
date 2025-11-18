import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/auth_service.dart';

class FriendProvider extends GetxService {
  final supabase = Get.find<AuthService>().supabase;

  var friends = <Map<String, dynamic>>[].obs;
  var incomingRequests = <Map<String, dynamic>>[].obs;
  var outgoingRequests = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFriends();
    loadFriendRequests();
  }

  Future<void> loadFriends() async {
    try {
      final user = supabase?.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          ?.from('friends')
          .select('*, profiles!friends_friend_id_fkey(*)')
          .eq('user_id', user.id);

      friends.assignAll(data ?? []);
    } catch (e) {
      print('Error loading friends: $e');
    }
  }

  Future<void> loadFriendRequests() async {
    try {
      final user = supabase?.auth.currentUser;
      if (user == null) return;

      // Incoming requests
      final incoming = await supabase
          ?.from('friend_requests')
          .select('*, profiles!friend_requests_sender_id_fkey(*)')
          .eq('receiver_id', user.id)
          .eq('status', 'pending');

      incomingRequests.assignAll(incoming ?? []);

      // Outgoing requests
      final outgoing = await supabase
          ?.from('friend_requests')
          .select('*, profiles!friend_requests_receiver_id_fkey(*)')
          .eq('sender_id', user.id)
          .eq('status', 'pending');

      outgoingRequests.assignAll(outgoing ?? []);
    } catch (e) {
      print('Error loading friend requests: $e');
    }
  }

  Future<void> sendFriendRequest(String receiverId) async {
    try {
      final user = supabase?.auth.currentUser;
      if (user == null) return;

      await supabase?.from('friend_requests').insert({
        'sender_id': user.id,
        'receiver_id': receiverId,
        'status': 'pending',
      });

      loadFriendRequests();
      Get.snackbar('Success', 'Friend request sent');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send friend request: $e');
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final user = supabase?.auth.currentUser;
      if (user == null) return;

      // Update request status
      await supabase
          ?.from('friend_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);

      // Add to friends
      final request = await supabase
          ?.from('friend_requests')
          .select('sender_id')
          .eq('id', requestId)
          .single();

      await supabase?.from('friends').insert({
        'user_id': user.id,
        'friend_id': request?['sender_id'],
      });

      await supabase?.from('friends').insert({
        'user_id': request?['sender_id'],
        'friend_id': user.id,
      });

      loadFriends();
      loadFriendRequests();
      Get.snackbar('Success', 'Friend request accepted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept friend request: $e');
    }
  }

  Future<void> declineFriendRequest(String requestId) async {
    try {
      await supabase
          ?.from('friend_requests')
          .update({'status': 'declined'})
          .eq('id', requestId);

      loadFriendRequests();
      Get.snackbar('Success', 'Friend request declined');
    } catch (e) {
      Get.snackbar('Error', 'Failed to decline friend request: $e');
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try {
      await supabase?.from('friend_requests').delete().eq('id', requestId);

      loadFriendRequests();
      Get.snackbar('Success', 'Friend request cancelled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel friend request: $e');
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      final user = supabase?.auth.currentUser;
      if (user == null) return;

      await supabase
          ?.from('friends')
          .delete()
          .or(
            'and(user_id.eq.${user.id},friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.${user.id})',
          );

      loadFriends();
      Get.snackbar('Success', 'Friend removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove friend: $e');
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final currentUser = supabase?.auth.currentUser;
      if (currentUser == null) return;

      await supabase?.from('blocked_users').insert({
        'blocker_id': currentUser.id,
        'blocked_id': userId,
      });

      // Remove from friends if they are friends
      removeFriend(userId);

      Get.snackbar('Success', 'User blocked');
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user: $e');
    }
  }

  Future<void> reportUser(String userId) async {
    try {
      final currentUser = supabase?.auth.currentUser;
      if (currentUser == null) return;

      await supabase?.from('reports').insert({
        'reporter_id': currentUser.id,
        'reported_id': userId,
        'reason': 'Inappropriate behavior', // Default reason
      });

      Get.snackbar('Success', 'User reported');
    } catch (e) {
      Get.snackbar('Error', 'Failed to report user: $e');
    }
  }
}
