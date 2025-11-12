import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/providers/friend_provider.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with TickerProviderStateMixin {
  final FriendProvider friendProvider = Get.put(FriendProvider());
  final UserProvider userProvider = Get.put(UserProvider());

  late TabController _tabController;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    friendProvider.loadFriendsData();
    _refreshController.refreshCompleted();
  }

  void _showContextMenu(BuildContext context, Map<String, dynamic> user) {
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
              ListTile(
                leading: Icon(Iconsax.user_bold, size: 20.sp),
                title: Text('View Profile', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed('${AppRoutes.otherProfile}/${user['id']}');
                },
              ),
              ListTile(
                leading: Icon(Iconsax.message_bold, size: 20.sp),
                title: Text('Message', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to chat
                  Get.toNamed(AppRoutes.chatRoom);
                },
              ),
              ListTile(
                leading: Icon(Iconsax.call_bold, size: 20.sp),
                title: Text('Audio Call', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.pop(context);
                  // Start audio call
                },
              ),
              ListTile(
                leading: Icon(Iconsax.video_bold, size: 20.sp),
                title: Text('Video Call', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.pop(context);
                  // Start video call
                },
              ),
              ListTile(
                leading: Icon(Iconsax.security_bold, size: 20.sp),
                title: Text(
                  'Block',
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  friendProvider.blockUser(user['id']);
                },
              ),
              ListTile(
                leading: Icon(Iconsax.warning_2_bold, size: 20.sp),
                title: Text(
                  'Report',
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  friendProvider.reportUser(user['id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList(
    List<Map<String, dynamic>> users, {
    bool showOnlineIndicator = false,
  }) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.people_bold, size: 40.sp, color: Colors.grey),
            SizedBox(height: 8.sp),
            Text(
              'No friends found',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => Get.toNamed(AppRoutes.chatRoom),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Iconsax.message_bold,
                label: 'Message',
              ),
              SlidableAction(
                onPressed: (_) => _showContextMenu(context, user),
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                icon: Iconsax.more_bold,
                label: 'More',
              ),
            ],
          ),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 20.sp,
                  backgroundImage: CachedNetworkImageProvider(user['avatar']),
                ),
                if (showOnlineIndicator && user['isOnline'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 8.sp,
                      height: 8.sp,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5.sp),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(user['name'], style: TextStyle(fontSize: 16.sp)),
            subtitle: Text(
              user['bio'].isEmpty ? 'No bio' : user['bio'],
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: Icon(Iconsax.more_bold, size: 16.sp),
              onPressed: () => _showContextMenu(context, user),
            ),
            onTap: () => Get.toNamed('${AppRoutes.otherProfile}/${user['id']}'),
          ),
        );
      },
    );
  }

  Widget _buildRequestsList() {
    final allRequests = [
      ...friendProvider.incomingRequests.map((r) => {...r, 'type': 'incoming'}),
      ...friendProvider.outgoingRequests.map((r) => {...r, 'type': 'outgoing'}),
    ];

    if (allRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.user_add_bold, size: 40.sp, color: Colors.grey),
            SizedBox(height: 8.sp),
            Text(
              'No friend requests',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: allRequests.length,
      itemBuilder: (context, index) {
        final request = allRequests[index];
        final isIncoming = request['type'] == 'incoming';

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 4.sp),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.sp,
                  backgroundImage: CachedNetworkImageProvider(
                    isIncoming
                        ? request['senderAvatar']
                        : request['receiverAvatar'],
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIncoming
                            ? request['senderName']
                            : request['receiverName'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isIncoming ? 'Wants to be friends' : 'Request sent',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (isIncoming) ...[
                  ElevatedButton(
                    onPressed: () =>
                        friendProvider.acceptFriendRequest(request['id']),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.sp,
                        vertical: 6.sp,
                      ),
                    ),
                    child: Text('Accept', style: TextStyle(fontSize: 12.sp)),
                  ),
                  SizedBox(width: 8.sp),
                  OutlinedButton(
                    onPressed: () =>
                        friendProvider.declineFriendRequest(request['id']),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.sp,
                        vertical: 6.sp,
                      ),
                    ),
                    child: Text('Decline', style: TextStyle(fontSize: 12.sp)),
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: () =>
                        friendProvider.cancelFriendRequest(request['id']),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.sp,
                        vertical: 6.sp,
                      ),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 12.sp)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
        actions: [
          IconButton(
            icon: Icon(Iconsax.add_bold, size: 20.sp),
            onPressed: () => Get.toNamed(AppRoutes.search),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Online'),
            Tab(text: 'Requests'),
            Tab(text: 'Suggestions'),
          ],
          labelStyle: TextStyle(fontSize: 14.sp),
          unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        ),
      ),
      body: Obx(() {
        if (friendProvider.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: [
            SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildUserList(friendProvider.friends),
            ),
            SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildUserList(
                friendProvider.onlineFriends,
                showOnlineIndicator: true,
              ),
            ),
            SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildRequestsList(),
            ),
            SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _buildUserList(friendProvider.suggestions),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.search),
        child: Icon(Iconsax.add_bold, size: 20.sp),
      ),
    );
  }
}
