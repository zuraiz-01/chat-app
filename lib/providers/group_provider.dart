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
    // Load group data from Supabase database
    // Data will be fetched based on groupId parameter
  }

  void setupRealtime() {
    // Real-time subscriptions will be set up here
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
