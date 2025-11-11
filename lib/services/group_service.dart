import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getGroupInfo(String groupId) async {
    final response = await supabase
        .from('groups')
        .select()
        .eq('id', groupId)
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final response = await supabase
        .from('group_members')
        .select('*, profiles(name, avatar)')
        .eq('group_id', groupId);
    return response;
  }

  Future<List<Map<String, dynamic>>> getGroupMessages(
    String groupId, {
    int limit = 50,
  }) async {
    final response = await supabase
        .from('group_messages')
        .select()
        .eq('group_id', groupId)
        .order('timestamp', ascending: false)
        .limit(limit);
    return response;
  }

  Future<void> sendMessage(String groupId, Map<String, dynamic> message) async {
    await supabase.from('group_messages').insert(message);
  }

  Future<void> uploadMedia(String fileName, dynamic file) async {
    await supabase.storage.from('group_media').upload(fileName, file);
  }

  String getMediaUrl(String fileName) {
    return supabase.storage.from('group_media').getPublicUrl(fileName);
  }

  Future<void> updateMutePreference(
    String userId,
    String groupId,
    bool isMuted,
  ) async {
    await supabase.from('user_group_preferences').upsert({
      'user_id': userId,
      'group_id': groupId,
      'is_muted': isMuted,
    });
  }

  Future<void> leaveGroup(String userId, String groupId) async {
    await supabase
        .from('group_members')
        .delete()
        .eq('user_id', userId)
        .eq('group_id', groupId);
  }

  Future<void> pinMessage(int messageId, bool isPinned) async {
    await supabase
        .from('group_messages')
        .update({'is_pinned': isPinned})
        .eq('id', messageId);
  }

  Future<void> removeMember(String userId, String groupId) async {
    await supabase
        .from('group_members')
        .delete()
        .eq('user_id', userId)
        .eq('group_id', groupId);
  }
}
