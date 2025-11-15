import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends GetxController {
  final supabase = Supabase.instance.client;

  final Rx<User?> currentUser = Rx<User?>(null);
  final Rx<Map<String, dynamic>> userProfile = Rx<Map<String, dynamic>>({});
  final RxBool isLoading = true.obs;
  final RxBool isOnline = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
    setupRealtime();
  }

  void loadCurrentUser() async {
    try {
      final user = supabase.auth.currentUser;
      currentUser.value = user;

      if (user != null) {
        final userData = await supabase
            .from('profiles')
            .select(
              'id, username, avatar_url, full_name, bio, online_status, last_seen',
            )
            .eq('id', user.id)
            .single();

        userProfile.value = {
          'id': userData['id'],
          'username': userData['username'] ?? 'User',
          'avatar_url': userData['avatar_url'] ?? '',
          'full_name': userData['full_name'] ?? '',
          'bio': userData['bio'] ?? '',
          'online_status': userData['online_status'] ?? false,
          'last_seen': userData['last_seen'] ?? DateTime.now(),
        };
        isOnline.value = userData['online_status'] ?? false;
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

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').update(updates).eq('id', user.id);
        loadCurrentUser(); // Refresh
        Get.snackbar('Success', 'Profile updated');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    }
  }

  Future<void> setOnlineStatus(bool status) async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        isOnline.value = status;
        await supabase
            .from('profiles')
            .update({'online_status': status})
            .eq('id', user.id);
      }
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  Future<void> signOut() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await setOnlineStatus(false);
      }
      await supabase.auth.signOut();
      currentUser.value = null;
      userProfile.value = {};
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }
}
