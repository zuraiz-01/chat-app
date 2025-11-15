import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendProvider extends GetxController {
  var friends = <Map<String, dynamic>>[]
      .obs; // [{id, name, avatar, bio, isOnline, lastSeen}]
  var onlineFriends = <Map<String, dynamic>>[].obs;
  var incomingRequests = <Map<String, dynamic>>[]
      .obs; // [{id, senderId, senderName, senderAvatar, createdAt}]
  var outgoingRequests = <Map<String, dynamic>>[]
      .obs; // [{id, receiverId, receiverName, receiverAvatar, createdAt}]
  var suggestions =
      <Map<String, dynamic>>[].obs; // [{id, name, avatar, bio, mutualFriends}]
  var isLoading = true.obs;

  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    loadFriendsData();
    setupRealtime();
  }

  void loadFriendsData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        // Load friends
        final friendsData = await supabase
            .from('friends')
            .select(
              'friend_id, profiles!friends_friend_id_fkey(id, username, avatar_url, bio, is_online, last_seen)',
            )
            .eq('user_id', user.id)
            .eq('status', 'accepted');

        friends.value = friendsData.map((f) {
          final profile = f['profiles'];
          return {
            'id': profile['id'],
            'name': profile['name'] ?? 'Unknown',
            'avatar': profile['avatar'] ?? 'assets/logo.png',
            'bio': profile['bio'] ?? '',
            'isOnline': profile['is_online'] ?? false,
            'lastSeen': profile['last_seen'] ?? DateTime.now(),
          };
        }).toList();

        onlineFriends.value = friends.where((f) => f['isOnline']).toList();

        // Load incoming requests
        final incoming = await supabase
            .from('friend_requests')
            .select(
              'id, sender_id, profiles!friend_requests_sender_id_fkey(id, username, avatar_url), created_at',
            )
            .eq('receiver_id', user.id)
            .eq('status', 'pending');

        incomingRequests.value = incoming.map((r) {
          final profile = r['profiles'];
          return {
            'id': r['id'],
            'senderId': r['sender_id'],
            'senderName': profile['name'] ?? 'Unknown',
            'senderAvatar': profile['avatar'] ?? 'assets/logo.png',
            'createdAt': r['created_at'],
          };
        }).toList();

        // Load outgoing requests
        final outgoing = await supabase
            .from('friend_requests')
            .select(
              'id, receiver_id, profiles!friend_requests_receiver_id_fkey(id, username, avatar_url), created_at',
            )
            .eq('sender_id', user.id)
            .eq('status', 'pending');

        outgoingRequests.value = outgoing.map((r) {
          final profile = r['profiles'];
          return {
            'id': r['id'],
            'receiverId': r['receiver_id'],
            'receiverName': profile['name'] ?? 'Unknown',
            'receiverAvatar': profile['avatar'] ?? 'assets/logo.png',
            'createdAt': r['created_at'],
          };
        }).toList();

        // Load suggestions (simplified: random users not friends)
        final allUsers = await supabase
            .from('profiles')
            .select('id, name, avatar, bio')
            .neq('id', user.id)
            .limit(10);

        final friendIds = friends.map((f) => f['id']).toSet();
        final requestIds = incomingRequests.map((r) => r['senderId']).toSet()
          ..addAll(outgoingRequests.map((r) => r['receiverId']));

        suggestions.value = allUsers
            .where(
              (u) =>
                  !friendIds.contains(u['id']) && !requestIds.contains(u['id']),
            )
            .map(
              (u) => {
                'id': u['id'],
                'name': u['name'] ?? 'Unknown',
                'avatar': u['avatar'] ?? 'assets/logo.png',
                'bio': u['bio'] ?? '',
                'mutualFriends': 0, // Placeholder
              },
            )
            .toList();
      }
    } catch (e) {
      print('Error loading friends data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setupRealtime() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Friend requests
      supabase
          .channel('friend_requests_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'friend_requests',
            callback: (payload) {
              loadFriendsData(); // Reload all data
            },
          )
          .subscribe();

      // Friends table changes
      supabase
          .channel('friends_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'friends',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: user.id,
            ),
            callback: (payload) {
              loadFriendsData();
            },
          )
          .subscribe();

      // Online status changes
      supabase
          .channel('online_status')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'profiles',
            callback: (payload) {
              final updatedUser = payload.newRecord;
              final friendIndex = friends.indexWhere(
                (f) => f['id'] == updatedUser['id'],
              );
              if (friendIndex != -1) {
                friends[friendIndex]['isOnline'] = updatedUser['is_online'];
                friends[friendIndex]['lastSeen'] = updatedUser['last_seen'];
                onlineFriends.value = friends
                    .where((f) => f['isOnline'])
                    .toList();
                friends.refresh();
              }
            },
          )
          .subscribe();
    }
  }

  void sendFriendRequest(String receiverId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('friend_requests').insert({
          'sender_id': user.id,
          'receiver_id': receiverId,
          'status': 'pending',
        });
        loadFriendsData(); // Refresh
      }
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  void acceptFriendRequest(String requestId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        // Update request status
        await supabase
            .from('friend_requests')
            .update({'status': 'accepted'})
            .eq('id', requestId);

        // Add to friends table (assuming bidirectional)
        final request = incomingRequests.firstWhere(
          (r) => r['id'] == requestId,
        );
        await supabase.from('friends').insert([
          {'user_id': user.id, 'friend_id': request['senderId']},
          {'user_id': request['senderId'], 'friend_id': user.id},
        ]);

        loadFriendsData(); // Refresh

        // Send FCM notification (placeholder)
        // await sendFCMNotification(request['senderId'], 'Friend request accepted!');
      }
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  void declineFriendRequest(String requestId) async {
    try {
      await supabase
          .from('friend_requests')
          .update({'status': 'declined'})
          .eq('id', requestId);
      loadFriendsData(); // Refresh
    } catch (e) {
      print('Error declining friend request: $e');
    }
  }

  void cancelFriendRequest(String requestId) async {
    try {
      await supabase.from('friend_requests').delete().eq('id', requestId);
      loadFriendsData(); // Refresh
    } catch (e) {
      print('Error canceling friend request: $e');
    }
  }

  void removeFriend(String friendId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase
            .from('friends')
            .delete()
            .or(
              'and(user_id.eq.${user.id},friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.${user.id})',
            );
        loadFriendsData(); // Refresh
      }
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  void blockUser(String userId) async {
    // Placeholder for blocking
    print('Block user: $userId');
  }

  void reportUser(String userId) async {
    // Placeholder for reporting
    print('Report user: $userId');
  }
}
