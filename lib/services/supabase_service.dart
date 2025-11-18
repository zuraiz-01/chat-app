import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../service/auth_service.dart';

class SupabaseService {
  SupabaseClient? get _client => Get.find<AuthService>().supabase;

  SupabaseClient _getClient() {
    final client = _client;
    if (client == null) throw Exception('Supabase client not initialized');
    return client;
  }

  SupabaseClient? get client => _client;

  // ===========================
  // MARK: - Chat Rooms
  // ===========================

  /// Create a chat room (1-to-1 or group)
  Future<String> createChatRoom({
    required String name,
    required String createdBy,
    required List<String> members,
  }) async {
    final client = _getClient();

    final response = await client
        .from('chats')
        .insert({
          'name': name,
          'created_by': createdBy,
          'is_group': members.length > 2,
        })
        .select('id')
        .single();

    final chatId = response['id'];

    // Add members to participants table
    final participantRows = members
        .map((m) => {'chat_id': chatId, 'user_id': m})
        .toList();
    await client.from('chat_participants').insert(participantRows);

    return chatId;
  }

  /// Get all chat rooms for a user
  Future<List<Map<String, dynamic>>> getUserChatRooms(String userId) async {
    final client = _getClient();
    final response = await client
        .from('chat_participants')
        .select('chats(*), chat_id')
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return response.map((e) => e['chats'] as Map<String, dynamic>).toList();
  }

  /// Stream chat rooms in real-time
  Stream<List<Map<String, dynamic>>> getUserChatRoomsStream(String userId) {
    final client = _getClient();
    return client
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('updated_at')
        .map(
          (rows) => rows
              .where(
                (chat) =>
                    (chat['participants'] as List<dynamic>?)?.any(
                      (p) => p['user_id'] == userId,
                    ) ??
                    false,
              )
              .toList(),
        );
  }

  // ===========================
  // MARK: - Messages
  // ===========================

  /// Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    required String messageType,
    String? mediaUrl,
  }) async {
    final client = _getClient();
    await client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'media_url': mediaUrl,
    });

    // Update chat "updated_at"
    await client
        .from('chats')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', chatId);
  }

  /// Get all messages from a chat
  Future<List<Map<String, dynamic>>> getRoomMessages(
    String chatId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final client = _getClient();
    final response = await client
        .from('messages')
        .select('*')
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Stream messages in real-time
  Stream<List<Map<String, dynamic>>> getRoomMessagesStream(String chatId) {
    final client = _getClient();
    return client.from('messages').stream(primaryKey: ['id']).map((rows) {
      // rows is List<dynamic>, we filter manually
      return (rows as List<dynamic>)
          .where((row) => row['chat_id'] == chatId)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    });
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    final client = _getClient();
    await client.from('messages').update({'is_read': true}).eq('id', messageId);
  }

  /// Get unread message count
  Future<int> getUnreadMessageCount(String chatId, String userId) async {
    final client = _getClient();
    final response = await client
        .from('messages')
        .select('id')
        .eq('chat_id', chatId)
        .neq('sender_id', userId)
        .eq('is_read', false);

    return response.length;
  }
  // ===========================
  // MARK: - Friends
  // ===========================

  /// Get all friends for a user
  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    final client = _getClient();
    final response = await client
        .from('friends') // Make sure this table exists in Supabase
        .select('*, friend:profiles(*)') // optional: join with profiles table
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(response);
  }
  // ===========================
  // MARK: - Typing Status
  // ===========================

  /// Update typing status
  Future<void> setTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    final client = _getClient();
    final existing = await client
        .from('typing_status')
        .select('id')
        .eq('chat_id', chatId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      await client.from('typing_status').insert({
        'chat_id': chatId,
        'user_id': userId,
        'is_typing': isTyping,
      });
    } else {
      await client
          .from('typing_status')
          .update({'is_typing': isTyping})
          .eq('id', existing['id']);
    }
  }

  /// Stream typing users in a chat
  Stream<List<Map<String, dynamic>>> getTypingStatusStream(String chatId) {
    final client = _getClient();
    return client.from('typing_status').stream(primaryKey: ['id']).map((rows) {
      // rows is List<dynamic>, we filter manually
      return (rows as List<dynamic>)
          .where((row) => row['chat_id'] == chatId && row['is_typing'] == true)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    });
  }

  // ===========================
  // MARK: - Messages (Legacy Support)
  // ===========================

  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    return getRoomMessages(chatId);
  }

  Stream<List<Map<String, dynamic>>> getChatMessagesStream(String chatId) {
    return getRoomMessagesStream(chatId);
  }

  // ===========================
  // MARK: - Call Logs (NEW APPROACH)
  // ===========================

  Future<void> addCallLog({
    required String chatId,
    required String userId, // caller
    required int duration,
    required String callType, // 'voice' or 'video'
    required bool missed,
  }) async {
    final client = _getClient();
    await client.from('call_logs').insert({
      'chat_id': chatId,
      'user_id': userId,
      'duration': duration,
      'call_type': callType,
      'missed': missed,
    });
  }

  /// Get call logs by chatroom
  Future<List<Map<String, dynamic>>> getCallLogs(String chatId) async {
    final client = _getClient();
    final response = await client
        .from('call_logs')
        .select('*')
        .eq('chat_id', chatId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Stream call logs for a chatroom
  Stream<List<Map<String, dynamic>>> getCallLogsStream(String chatId) {
    final client = _getClient();
    return client
        .from('call_logs')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .map((rows) {
          return (rows as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
  }

  /// Stream all call logs for the authenticated user (filtered by RLS)
  Stream<List<Map<String, dynamic>>> getAllCallLogsStream() {
    final client = _getClient();
    return client
        .from('call_logs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) {
          return (rows as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
  }

  /// Get the other participant in a chat (excluding current user)
  Future<Map<String, dynamic>?> getOtherParticipant(
    String chatId,
    String currentUserId,
  ) async {
    final client = _getClient();
    final response = await client
        .from('chat_participants')
        .select('user_id, profiles(username, full_name)')
        .eq('chat_id', chatId)
        .neq('user_id', currentUserId)
        .limit(1)
        .single();

    return response['profiles'] as Map<String, dynamic>?;
  }

  /// Sign in user with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final client = _getClient();
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Return user info
        return {'id': response.user!.id, 'email': response.user!.email};
      } else {
        throw Exception('Failed to sign in');
      }
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
  }

  /// Add a user to an existing chat room
  Future<void> addRoomMember(String roomId, String userId) async {
    try {
      final client = _getClient();
      // Check if user is already a participant
      final existing = await client
          .from('chat_participants')
          .select('id')
          .eq('chat_id', roomId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        // Add new participant
        await client.from('chat_participants').insert({
          'chat_id': roomId,
          'user_id': userId,
        });

        // Optionally update the chat's updated_at
        await client
            .from('chats')
            .update({'updated_at': DateTime.now().toIso8601String()})
            .eq('id', roomId);
      }
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  // ===========================
  // MARK: - User Search
  // ===========================

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final client = _getClient();
    final response = await client
        .from('profiles')
        .select('id, username, avatar_url')
        .ilike('username', '%$query%')
        .limit(20);

    return List<Map<String, dynamic>>.from(response);
  }
}
