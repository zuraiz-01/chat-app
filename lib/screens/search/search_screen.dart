import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/providers/friend_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FriendProvider friendProvider = Get.put(FriendProvider());

  var searchResults = <Map<String, dynamic>>[].obs;
  var isSearching = false.obs;

  final supabase = Supabase.instance.client;

  void searchUsers(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    try {
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        final results = await supabase
            .from('profiles')
            .select('id, username, avatar_url, full_name')
            .neq('id', currentUser.id)
            .ilike('username', '%$query%')
            .limit(20);

        // Filter out friends and existing requests
        final friendIds = friendProvider.friends.map((f) => f['id']).toSet();
        final requestIds =
            friendProvider.incomingRequests.map((r) => r['senderId']).toSet()
              ..addAll(
                friendProvider.outgoingRequests.map((r) => r['receiverId']),
              );

        searchResults.value = results
            .where(
              (u) =>
                  !friendIds.contains(u['id']) && !requestIds.contains(u['id']),
            )
            .map(
              (u) => {
                'id': u['id'],
                'name': u['username'] ?? 'Unknown',
                'avatar': u['avatar_url'] ?? 'assets/logo.png',
                'bio': u['full_name'] ?? '',
              },
            )
            .toList();
      }
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      isSearching.value = false;
    }
  }

  void sendFriendRequest(String userId) {
    friendProvider.sendFriendRequest(userId);
    // Remove from search results
    searchResults.removeWhere((u) => u['id'] == userId);
  }

  void showInviteSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.sp)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Invite Friends',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.sp),
              ListTile(
                leading: Icon(Iconsax.link_bold, size: 20.sp),
                title: Text(
                  'Invite by Link',
                  style: TextStyle(fontSize: 16.sp),
                ),
                onTap: () {
                  // Generate invite link
                  final inviteLink =
                      'https://chatapp.com/invite/${supabase.auth.currentUser?.id}';
                  // Copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invite link copied: $inviteLink')),
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Iconsax.user_bold, size: 20.sp),
                title: Text(
                  'Find by Username',
                  style: TextStyle(fontSize: 16.sp),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Already on search screen
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
        actions: [
          IconButton(
            icon: Icon(Iconsax.add_bold, size: 20.sp),
            onPressed: showInviteSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.sp),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search, size: 18.sp),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.sp),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10.sp,
                  horizontal: 12.sp,
                ),
              ),
              onChanged: searchUsers,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (searchResults.isEmpty && _searchController.text.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.search_normal_bold,
                        size: 40.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8.sp),
                      Text(
                        'No users found',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20.sp,
                      backgroundImage: CachedNetworkImageProvider(
                        user['avatar'],
                      ),
                    ),
                    title: Text(
                      user['name'],
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    subtitle: Text(
                      user['bio'].isEmpty ? 'No bio' : user['bio'],
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => sendFriendRequest(user['id']),
                      child: Text('Add', style: TextStyle(fontSize: 14.sp)),
                    ),
                    onTap: () => Get.toNamed('/otherProfile/${user['id']}'),
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
