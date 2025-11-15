import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ===========================
  // MARK: - Chat Rooms
  // ===========================

  /// Create a chat room (1-to-1 or group)
  Future<String> createChatRoom({
    required String name,
    required String createdBy,
    required List<String> members,
  }) async {
    final response = await _client
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
    await _client.from('chat_participants').insert(participantRows);

    return chatId;
  }

  /// Get all chat rooms for a user
  Future<List<Map<String, dynamic>>> getUserChatRooms(String userId) async {
    final response = await _client
        .from('chat_participants')
        .select('chats(*), chat_id')
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return response.map((e) => e['chats'] as Map<String, dynamic>).toList();
  }

  /// Stream chat rooms in real-time
  Stream<List<Map<String, dynamic>>> getUserChatRoomsStream(String userId) {
    return _client
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
    await _client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'media_url': mediaUrl,
    });

    // Update chat "updated_at"
    await _client
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
    final response = await _client
        .from('messages')
        .select('*')
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Stream messages in real-time
  Stream<List<Map<String, dynamic>>> getRoomMessagesStream(String chatId) {
    return _client.from('messages').stream(primaryKey: ['id']).map((rows) {
      // rows is List<dynamic>, we filter manually
      return (rows as List<dynamic>)
          .where((row) => row['chat_id'] == chatId)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    });
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('id', messageId);
  }

  /// Get unread message count
  Future<int> getUnreadMessageCount(String chatId, String userId) async {
    final response = await _client
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
    final response = await _client
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
    final existing = await _client
        .from('typing_status')
        .select('id')
        .eq('chat_id', chatId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing == null) {
      await _client.from('typing_status').insert({
        'chat_id': chatId,
        'user_id': userId,
        'is_typing': isTyping,
      });
    } else {
      await _client
          .from('typing_status')
          .update({'is_typing': isTyping})
          .eq('id', existing['id']);
    }
  }

  /// Stream typing users in a chat
  Stream<List<Map<String, dynamic>>> getTypingStatusStream(String chatId) {
    return _client.from('typing_status').stream(primaryKey: ['id']).map((rows) {
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
  // MARK: - Call Logs
  // ===========================

  Future<void> addCallLog({
    required String initiatorId,
    required String recipientId,
    required int duration,
    required String callType, // 'voice' or 'video'
    required bool missed,
  }) async {
    await _client.from('call_logs').insert({
      'initiator_id': initiatorId,
      'recipient_id': recipientId,
      'duration': duration,
      'call_type': callType,
      'missed': missed,
    });
  }

  Future<List<Map<String, dynamic>>> getCallLogs(String userId) async {
    final response = await _client
        .from('call_logs')
        .select('*')
        .or('initiator_id.eq.$userId,recipient_id.eq.$userId')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Stream<List<Map<String, dynamic>>> getCallLogsStream(String userId) {
    return _client
        .from('call_logs')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) {
          // filter manually because .or() is not supported in streams
          return (rows as List<dynamic>)
              .where(
                (row) =>
                    row['initiator_id'] == userId ||
                    row['recipient_id'] == userId,
              )
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        });
  }

  /// Sign in user with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
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
      // Check if user is already a participant
      final existing = await _client
          .from('chat_participants')
          .select('id')
          .eq('chat_id', roomId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        // Add new participant
        await _client.from('chat_participants').insert({
          'chat_id': roomId,
          'user_id': userId,
        });

        // Optionally update the chat's updated_at
        await _client
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
    final response = await _client
        .from('profiles')
        .select('id, username, avatar_url')
        .ilike('username', '%$query%')
        .limit(20);

    return List<Map<String, dynamic>>.from(response);
  }
}
