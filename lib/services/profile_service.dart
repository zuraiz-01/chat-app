import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // Update user profile
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _supabase.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Upload avatar to Supabase Storage
  Future<String?> uploadAvatar(String userId, File file) async {
    try {
      final fileName = '$userId-avatar.png';
      final response = await _supabase.storage
          .from('avatars')
          .upload(fileName, file);

      if (response.isNotEmpty) {
        final publicUrl = _supabase.storage
            .from('avatars')
            .getPublicUrl(fileName);
        return publicUrl;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
