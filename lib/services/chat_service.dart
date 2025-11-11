import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all chats where current user is a participant
  Future<List<Map<String, dynamic>>> fetchChats(String userId) async {
    try {
      final response = await _supabase
          .from('chats')
          .select('id, participants, created_at')
          .contains('participants', [userId]);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch chats: $e');
    }
  }

  // Fetch last message for a chat
  Future<Map<String, dynamic>?> fetchLastMessage(String chatId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('content, timestamp, sender_id')
          .eq('chat_id', chatId)
          .order('timestamp', ascending: false)
          .limit(1)
          .single();
      return response;
    } catch (e) {
      // No messages yet
      return null;
    }
  }

  // Fetch user profile for a participant (other than current user)
  Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, name, avatar_url, online_status')
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Setup realtime subscription for messages
  void setupMessageRealtime(String userId, Function onUpdate) {
    _supabase
        .channel('messages_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            onUpdate();
          },
        )
        .subscribe();
  }

  // Setup realtime for online status
  void setupOnlineStatusRealtime(Function onUpdate) {
    _supabase
        .channel('online_status')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          callback: (payload) {
            onUpdate();
          },
        )
        .subscribe();
  }
}
