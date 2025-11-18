import 'package:chat_app/services/supabase_service.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final _supabaseService = SupabaseService();

  // Lazy getter for Supabase client
  SupabaseClient? get _supabase => Get.find<AuthService>().supabase;

  // ===========================
  // Fetch all chats for a user
  // ===========================
  Future<List<Map<String, dynamic>>> fetchChats(String userId) async {
    try {
      return await _supabaseService.getUserChatRooms(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch chats: $e');
      return [];
    }
  }

  // ===========================
  // Get all messages from a room
  // ===========================
  Future<List<Map<String, dynamic>>> getRoomMessages(
    String roomId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _supabaseService.getRoomMessages(
        roomId,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: $e');
      return [];
    }
  }

  // ===========================
  // Stream messages in real-time for a room
  // ===========================
  Stream<List<Map<String, dynamic>>> roomMessagesStream(String roomId) {
    try {
      return _supabaseService.getRoomMessagesStream(roomId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to stream messages: $e');
      return const Stream.empty();
    }
  }

  // ===========================
  // Sending Messages
  // ===========================
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String messageType = 'text',
    String? mediaUrl,
  }) async {
    try {
      if (_supabase?.auth.currentUser == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }
      await _supabaseService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        content: content,
        messageType: messageType,
        mediaUrl: mediaUrl,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }

  // ===========================
  // Chat List
  // ===========================
  Future<List<Map<String, dynamic>>> fetchUserChats(String userId) async {
    try {
      return await _supabaseService.getUserChatRooms(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch chats: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> chatListStream(String userId) {
    return _supabaseService.getUserChatRoomsStream(userId);
  }

  // ===========================
  // Chat Messages
  // ===========================
  Future<List<Map<String, dynamic>>> getChatMessages(
    String chatId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _supabaseService.getRoomMessages(
        chatId,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> chatMessagesStream(String chatId) {
    return _supabaseService.getRoomMessagesStream(chatId);
  }

  // ===========================
  // Message Read / Unread
  // ===========================
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _supabaseService.markMessageAsRead(messageId);
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  Future<int> getUnreadCount(String chatId, String userId) async {
    try {
      return await _supabaseService.getUnreadMessageCount(chatId, userId);
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // ===========================
  // Group Chat Management
  // ===========================
  Future<String?> createGroupChat({
    required String name,
    required String createdBy,
    required List<String> members,
  }) async {
    try {
      final chatId = await _supabaseService.createChatRoom(
        name: name,
        createdBy: createdBy,
        members: members,
      );
      Get.snackbar('Success', 'Group chat created');
      return chatId;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create group: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserGroups(String userId) async {
    try {
      return await _supabaseService.getUserChatRooms(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load groups: $e');
      return [];
    }
  }

  Future<void> sendGroupMessage({
    required String chatId,
    required String senderId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      if (_supabase?.auth.currentUser == null) return;
      await _supabaseService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        content: content,
        messageType: messageType,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send group message: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> groupMessagesStream(String chatId) {
    return _supabaseService.getRoomMessagesStream(chatId);
  }

  // ===========================
  // Search
  // ===========================
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      return await _supabaseService.searchUsers(query);
    } catch (e) {
      Get.snackbar('Error', 'Search failed: $e');
      return [];
    }
  }

  // ===========================
  // Realtime Listeners
  // ===========================
  RealtimeChannel? _messageChannel;
  RealtimeChannel? _statusChannel;

  void setupMessageRealtime(String userId, Function onUpdate) {
    final user = _supabase?.auth.currentUser;
    if (user == null) {
      print("❌ User not logged in. Cannot setup realtime messages.");
      return;
    }
    _messageChannel = _supabase
        ?.channel('messages_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) => onUpdate(),
        )
        .subscribe();
  }

  void setupOnlineStatusRealtime(Function onUpdate) {
    _statusChannel = _supabase
        ?.channel('online_status')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          callback: (payload) => onUpdate(),
        )
        .subscribe();
  }

  Future<void> disposeRealtime() async {
    await _messageChannel?.unsubscribe();
    await _statusChannel?.unsubscribe();
    _messageChannel = null;
    _statusChannel = null;
  }
}
