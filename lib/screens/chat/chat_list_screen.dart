import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _searchController = TextEditingController();
  final ChatProvider chatProvider = Get.put(ChatProvider());
  final UserProvider userProvider = Get.put(UserProvider());
  final SupabaseService _supabaseService = SupabaseService();

  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  late final User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = Supabase.instance.client.auth.currentUser!;
    loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Fetch users excluding current user
  Future<void> loadUsers() async {
    try {
      isLoading.value = true;

      final response = await Supabase.instance.client
          .from('profiles')
          .select('id, username, avatar_url, full_name')
          .neq('id', currentUser.id)
          .order('username', ascending: true);

      users.assignAll(List<Map<String, dynamic>>.from(response));
    } catch (e, st) {
      print('Error loading users: $e\n$st');
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Create or get private chat room
  Future<String> getOrCreateChatRoom(String otherUserId) async {
    try {
      // Check if chat already exists
      final userChatIds = await _getUserChatIds(currentUser.id);

      for (final chatId in userChatIds) {
        final participants = await Supabase.instance.client
            .from('chat_participants')
            .select('user_id')
            .eq('chat_id', chatId);

        final participantIds = participants
            .map((p) => p['user_id'] as String)
            .toList();

        if (participantIds.contains(currentUser.id) &&
            participantIds.contains(otherUserId) &&
            participantIds.length == 2) {
          return chatId;
        }
      }

      // Create new private chat
      final chatResponse = await Supabase.instance.client
          .from('chats')
          .insert({
            'name': 'Private Chat',
            'is_group': false,
            'created_by': currentUser.id,
          })
          .select('id')
          .single();

      final chatId = chatResponse['id'];

      // Add participants safely (RLS friendly)
      await Supabase.instance.client.from('chat_participants').insert({
        'chat_id': chatId,
        'user_id': currentUser.id,
      });

      await Supabase.instance.client.from('chat_participants').insert({
        'chat_id': chatId,
        'user_id': otherUserId,
      });

      return chatId;
    } catch (e, st) {
      print('Error creating/getting chat room: $e\n$st');
      rethrow;
    }
  }

  Future<List<String>> _getUserChatIds(String userId) async {
    final response = await Supabase.instance.client
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', userId);

    return (response as List).map((e) => e['chat_id'] as String).toList();
  }

  // ✅ Search filter
  List<Map<String, dynamic>> getFilteredUsers() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return users;

    return users.where((user) {
      final username = (user['username'] ?? '').toLowerCase();
      final fullName = (user['full_name'] ?? '').toLowerCase();
      return username.contains(query) || fullName.contains(query);
    }).toList();
  }

  // ✅ Sign out
  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Get.offAllNamed('/auth');
    } catch (e) {
      print('Error signing out: $e');
      Get.snackbar('Error', 'Failed to sign out');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(fontSize: 18.sp)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 20.sp),
            onPressed: loadUsers,
          ),
          IconButton(
            icon: Icon(Icons.logout, size: 20.sp),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.sp),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search, size: 18.sp),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18.sp),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.sp),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.sp,
                  horizontal: 16.sp,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Users list
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredUsers = getFilteredUsers();

              if (filteredUsers.isEmpty) {
                return Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'No users found'
                        : 'No results for "${_searchController.text}"',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];

                  return Card(
                    margin: EdgeInsets.symmetric(
                      vertical: 6.sp,
                      horizontal: 10.sp,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20.sp,
                        backgroundImage: user['avatar_url'] != null
                            ? CachedNetworkImageProvider(user['avatar_url'])
                            : null,
                        backgroundColor: Colors.blue.shade300,
                        child: user['avatar_url'] == null
                            ? Text(
                                (user['username'] ?? 'U')[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        user['username'] ?? 'Unknown User',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      subtitle: Text(
                        user['full_name'] ?? '',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.call,
                              size: 18.sp,
                              color: Colors.blue,
                            ),
                            onPressed: () async {
                              final roomId = await getOrCreateChatRoom(
                                user['id'],
                              );
                              Get.toNamed(
                                AppRoutes.chatRoom,
                                parameters: {
                                  'chatId': roomId,
                                  'otherUserId': user['id'],
                                  'otherUserName':
                                      user['username'] ?? 'Unknown',
                                  'isVideoCall': 'false',
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.videocam,
                              size: 18.sp,
                              color: Colors.blue,
                            ),
                            onPressed: () async {
                              final roomId = await getOrCreateChatRoom(
                                user['id'],
                              );
                              Get.toNamed(
                                AppRoutes.chatRoom,
                                parameters: {
                                  'chatId': roomId,
                                  'otherUserId': user['id'],
                                  'otherUserName':
                                      user['username'] ?? 'Unknown',
                                  'isVideoCall': 'true',
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        final roomId = await getOrCreateChatRoom(user['id']);
                        Get.toNamed(
                          AppRoutes.chatRoom,
                          parameters: {
                            'chatId': roomId,
                            'otherUserId': user['id'],
                            'otherUserName': user['username'] ?? 'Unknown',
                          },
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
