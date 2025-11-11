import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends GetxController {
  var currentUser = {}.obs; // {id, name, avatar, bio, isOnline, lastSeen}
  var isLoading = true.obs;

  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
    setupRealtime();
  }

  void loadCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final userData = await supabase
            .from('profiles')
            .select('id, name, avatar, bio, is_online, last_seen')
            .eq('id', user.id)
            .single();

        currentUser.value = {
          'id': userData['id'],
          'name': userData['name'] ?? 'User',
          'avatar': userData['avatar'] ?? 'assets/logo.png',
          'bio': userData['bio'] ?? '',
          'isOnline': userData['is_online'] ?? false,
          'lastSeen': userData['last_seen'] ?? DateTime.now(),
        };
      }
    } catch (e) {
      print('Error loading current user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setupRealtime() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      supabase
          .channel('user_profile_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: user.id,
            ),
            callback: (payload) {
              loadCurrentUser(); // Reload user data
            },
          )
          .subscribe();
    }
  }

  void updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update(updates).eq('id', user.id);
        loadCurrentUser(); // Refresh
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }
}
