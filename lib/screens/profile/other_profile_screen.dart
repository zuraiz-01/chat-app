import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/providers/friend_provider.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtherProfileScreen extends StatefulWidget {
  final String userId;

  const OtherProfileScreen({super.key, required this.userId});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  final FriendProvider friendProvider = Get.put(FriendProvider());
  final UserProvider userProvider = Get.put(UserProvider());

  var userData = {}.obs;
  var isLoading = true.obs;
  var isFriend = false.obs;
  var hasSentRequest = false.obs;
  var hasReceivedRequest = false.obs;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    try {
      final data = await supabase
          .from('profiles')
          .select('id, name, avatar, bio, is_online, last_seen')
          .eq('id', widget.userId)
          .single();

      userData.value = {
        'id': data['id'],
        'name': data['name'] ?? 'Unknown',
        'avatar': data['avatar'] ?? 'assets/logo.png',
        'bio': data['bio'] ?? '',
        'isOnline': data['is_online'] ?? false,
        'lastSeen': data['last_seen'] ?? DateTime.now(),
      };

      // Check friendship status
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null) {
        final friendship = await supabase
            .from('friends')
            .select()
            .or(
              'and(user_id.eq.${currentUser.id},friend_id.eq.${widget.userId}),and(user_id.eq.${widget.userId},friend_id.eq.${currentUser.id})',
            )
            .single()
            .catchError((_) => null);

        isFriend.value = friendship != null;

        if (!isFriend.value) {
          // Check outgoing request
          final outgoing = await supabase
              .from('friend_requests')
              .select()
              .eq('sender_id', currentUser.id)
              .eq('receiver_id', widget.userId)
              .eq('status', 'pending')
              .single()
              .catchError((_) => null);

          hasSentRequest.value = outgoing != null;

          // Check incoming request
          final incoming = await supabase
              .from('friend_requests')
              .select()
              .eq('sender_id', widget.userId)
              .eq('receiver_id', currentUser.id)
              .eq('status', 'pending')
              .single()
              .catchError((_) => null);

          hasReceivedRequest.value = incoming != null;
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void sendFriendRequest() {
    friendProvider.sendFriendRequest(widget.userId);
    hasSentRequest.value = true;
  }

  void acceptFriendRequest() {
    // Find the request ID
    final request = friendProvider.incomingRequests.firstWhere(
      (r) => r['senderId'] == widget.userId,
      orElse: () => {},
    );
    if (request.isNotEmpty) {
      friendProvider.acceptFriendRequest(request['id']);
      isFriend.value = true;
      hasReceivedRequest.value = false;
    }
  }

  void declineFriendRequest() {
    final request = friendProvider.incomingRequests.firstWhere(
      (r) => r['senderId'] == widget.userId,
      orElse: () => {},
    );
    if (request.isNotEmpty) {
      friendProvider.declineFriendRequest(request['id']);
      hasReceivedRequest.value = false;
    }
  }

  void removeFriend() {
    friendProvider.removeFriend(widget.userId);
    isFriend.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            isLoading.value ? 'Profile' : userData['name'],
            style: TextStyle(fontSize: 18.sp),
          ),
        ),
        toolbarHeight: 60.sp,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'block':
                  friendProvider.blockUser(widget.userId);
                  break;
                case 'report':
                  friendProvider.reportUser(widget.userId);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'block', child: Text('Block')),
              const PopupMenuItem(value: 'report', child: Text('Report')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40.sp,
                          backgroundImage: CachedNetworkImageProvider(
                            userData['avatar'],
                          ),
                        ),
                        if (userData['isOnline'])
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12.sp,
                              height: 12.sp,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.sp,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.sp),
                    Text(
                      userData['name'],
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (userData['bio'].isNotEmpty) ...[
                      SizedBox(height: 8.sp),
                      Text(
                        userData['bio'],
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: 16.sp),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isFriend.value) ...[
                          ElevatedButton.icon(
                            onPressed: () =>
                                Get.toNamed('/chatRoom'), // Placeholder
                            icon: Icon(Iconsax.message_bold, size: 16.sp),
                            label: Text(
                              'Message',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          SizedBox(width: 8.sp),
                          OutlinedButton.icon(
                            onPressed: () {}, // Placeholder for call
                            icon: Icon(Iconsax.call_bold, size: 16.sp),
                            label: Text(
                              'Call',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          SizedBox(width: 8.sp),
                          OutlinedButton(
                            onPressed: removeFriend,
                            child: Text(
                              'Remove Friend',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ] else if (hasSentRequest.value) ...[
                          OutlinedButton(
                            onPressed: () {
                              // Cancel request
                              final request = friendProvider.outgoingRequests
                                  .firstWhere(
                                    (r) => r['receiverId'] == widget.userId,
                                    orElse: () => {},
                                  );
                              if (request.isNotEmpty) {
                                friendProvider.cancelFriendRequest(
                                  request['id'],
                                );
                                hasSentRequest.value = false;
                              }
                            },
                            child: Text(
                              'Cancel Request',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ] else if (hasReceivedRequest.value) ...[
                          ElevatedButton(
                            onPressed: acceptFriendRequest,
                            child: Text(
                              'Accept',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          SizedBox(width: 8.sp),
                          OutlinedButton(
                            onPressed: declineFriendRequest,
                            child: Text(
                              'Decline',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ] else ...[
                          ElevatedButton(
                            onPressed: sendFriendRequest,
                            child: Text(
                              'Add Friend',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Additional sections can be added here (posts, mutual friends, etc.)
            ],
          ),
        );
      }),
    );
  }
}
