import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/auth_service.dart';

class GroupService {
  final supabase = Get.find<AuthService>().supabase;

  Future<Map<String, dynamic>?> getGroupInfo(String groupId) async {
    if (supabase == null) return null;
    final response = await supabase!
        .from('groups')
        .select()
        .eq('id', groupId)
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    if (supabase == null) return [];
    final response = await supabase!
        .from('group_members')
        .select('*, profiles(username, avatar_url)')
        .eq('group_id', groupId);
    return response;
  }

  Future<List<Map<String, dynamic>>> getGroupMessages(
    String groupId, {
    int limit = 50,
  }) async {
    if (supabase == null) return [];
    final response = await supabase!
        .from('group_messages')
        .select()
        .eq('group_id', groupId)
        .order('timestamp', ascending: false)
        .limit(limit);
    return response;
  }

  Future<void> sendMessage(String groupId, Map<String, dynamic> message) async {
    if (supabase == null) return;
    await supabase!.from('group_messages').insert(message);
  }

  Future<void> uploadMedia(String fileName, dynamic file) async {
    if (supabase == null) return;
    await supabase!.storage.from('group_media').upload(fileName, file);
  }

  String getMediaUrl(String fileName) {
    if (supabase == null) return '';
    return supabase!.storage.from('group_media').getPublicUrl(fileName);
  }

  Future<void> updateMutePreference(
    String userId,
    String groupId,
    bool isMuted,
  ) async {
    if (supabase == null) return;
    await supabase!.from('user_group_preferences').upsert({
      'user_id': userId,
      'group_id': groupId,
      'is_muted': isMuted,
    });
  }

  Future<void> leaveGroup(String userId, String groupId) async {
    if (supabase == null) return;
    await supabase!
        .from('group_members')
        .delete()
        .eq('user_id', userId)
        .eq('group_id', groupId);
  }

  Future<void> pinMessage(int messageId, bool isPinned) async {
    if (supabase == null) return;
    await supabase!
        .from('group_messages')
        .update({'is_pinned': isPinned})
        .eq('id', messageId);
  }

  Future<void> removeMember(String userId, String groupId) async {
    if (supabase == null) return;
    await supabase!
        .from('group_members')
        .delete()
        .eq('user_id', userId)
        .eq('group_id', groupId);
  }
}
