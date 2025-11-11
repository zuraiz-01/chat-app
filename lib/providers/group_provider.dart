import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupProvider extends GetxController {
  final String groupId;
  GroupProvider(this.groupId);

  var groupInfo = {}.obs; // {name, description, avatar, createdAt, adminId}
  var members =
      <Map<String, dynamic>>[].obs; // [{id, name, avatar, role, isOnline}]
  var messages = <Map<String, dynamic>>[]
      .obs; // [{id, senderId, senderName, message, type, timestamp, mentions, isPinned}]
  var pinnedMessages = <Map<String, dynamic>>[].obs;
  var typingUsers = <String>[].obs; // List of user names typing
  var isMuted = false.obs;
  var unreadCount = 0.obs;
  var hasLeftGroup = false.obs;

  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    loadGroupData();
    setupRealtime();
  }

  void loadGroupData() {
    // Mock data for now
    groupInfo.value = {
      'name': 'Group Chat',
      'description': 'A fun group',
      'avatar': 'assets/logo.png',
      'createdAt': DateTime.now(),
      'adminId': 'admin1',
    };
    members.value = [
      {
        'id': 'user1',
        'name': 'Alice',
        'avatar': 'assets/logo.png',
        'role': 'admin',
        'isOnline': true,
      },
      {
        'id': 'user2',
        'name': 'Bob',
        'avatar': 'assets/logo.png',
        'role': 'member',
        'isOnline': false,
      },
      {
        'id': 'user3',
        'name': 'Charlie',
        'avatar': 'assets/logo.png',
        'role': 'member',
        'isOnline': true,
      },
    ];
    messages.value = [
      {
        'id': 1,
        'senderId': 'user1',
        'senderName': 'Alice',
        'message': 'Hey everyone!',
        'type': 'text',
        'timestamp': DateTime.now().subtract(Duration(minutes: 10)),
        'mentions': [],
        'isPinned': false,
      },
      {
        'id': 2,
        'senderId': 'user2',
        'name': 'Bob',
        'message': 'Hi @Alice!',
        'type': 'text',
        'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
        'mentions': ['user1'],
        'isPinned': true,
      },
    ];
    pinnedMessages.value = messages.where((m) => m['isPinned']).toList();
  }

  void setupRealtime() {
    // Messages channel
    supabase
        .channel('group_messages_$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'group_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) {
            messages.add(payload.newRecord);
            unreadCount.value++;
          },
        )
        .subscribe();

    // Typing channel
    supabase
        .channel('group_typing_$groupId')
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            if (payload['isTyping']) {
              typingUsers.add(payload['userName']);
            } else {
              typingUsers.remove(payload['userName']);
            }
          },
        )
        .subscribe();

    // Membership changes
    supabase
        .channel('group_members_$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) {
            loadGroupData(); // Reload members
          },
        )
        .subscribe();
  }

  void sendMessage(
    String message, {
    String type = 'text',
    List<String> mentions = const [],
  }) {
    final newMessage = {
      'group_id': groupId,
      'sender_id': supabase.auth.currentUser!.id,
      'sender_name': 'Me', // Replace with actual user name
      'message': message,
      'type': type,
      'timestamp': DateTime.now(),
      'mentions': mentions,
      'is_pinned': false,
    };
    supabase.from('group_messages').insert(newMessage);
    messages.add(newMessage);
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    // Update in Supabase user preferences
  }

  void leaveGroup() {
    hasLeftGroup.value = true;
    // Supabase: remove from group_members
  }

  void pinMessage(int messageId) {
    // Only admin can pin
    final message = messages.firstWhere((m) => m['id'] == messageId);
    message['isPinned'] = !message['isPinned'];
    pinnedMessages.value = messages.where((m) => m['isPinned']).toList();
    // Update in Supabase
  }

  void removeMember(String userId) {
    // Only admin
    members.removeWhere((m) => m['id'] == userId);
    // Supabase: delete from group_members
  }

  List<String> getMentionSuggestions(String query) {
    return members
        .where((m) => m['name'].toLowerCase().contains(query.toLowerCase()))
        .map((m) => m['name'] as String)
        .toList();
  }
}
