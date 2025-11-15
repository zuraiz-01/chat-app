import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/supabase_service.dart';
import 'package:get/get.dart';

class ChatProvider extends GetxController {
  final ChatService _chatService = ChatService();

  final RxList<Map<String, dynamic>> chatList = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final SupabaseService _supabaseService = SupabaseService();
  // ===========================
  // Load chats once
  // ===========================
  Future<void> loadChats(String userId) async {
    try {
      isLoading.value = true;
      final chats = await _chatService.fetchChats(userId);
      chatList.value = chats;
    } catch (e) {
      print('Error loading chats: $e');
      Get.snackbar('Error', 'Failed to load chats');
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================
  // Stream chats in real-time
  // ===========================
  Stream<List<Map<String, dynamic>>> streamChats(String userId) {
    return _chatService.chatListStream(userId);
  }

  // ===========================
  // Load messages of a room
  // ===========================
  Future<void> loadConversation(String roomId) async {
    try {
      isLoading.value = true;
      final msgs = await _chatService.getRoomMessages(roomId);
      messages.value = msgs;
    } catch (e) {
      print('Error loading conversation: $e');
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================
  // Stream messages in real-time
  // ===========================
  Stream<List<Map<String, dynamic>>> streamConversation(String roomId) {
    return _chatService.roomMessagesStream(roomId);
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String message,
    String messageType = 'text',
  }) async {
    try {
      // Call SupabaseService to send the message
      await _supabaseService.sendMessage(
        chatId: roomId, // map roomId -> chatId
        senderId: senderId,
        content: message, // map message -> content
        messageType: messageType,
      );

      // Optionally, add the message locally for instant UI update
      messages.insert(0, {
        'chat_id': roomId,
        'sender_id': senderId,
        'content': message,
        'message_type': messageType,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  // ===========================
  // Search users
  // ===========================
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    try {
      searchQuery.value = query;
      final results = await _chatService.searchUsers(query);
      searchResults.value = results;
    } catch (e) {
      print('Error searching users: $e');
      Get.snackbar('Error', 'Failed to search users');
    }
  }

  // ===========================
  // Clear search
  // ===========================
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }
}
