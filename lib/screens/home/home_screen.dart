import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ChatService _chatService = ChatService();
  final UserProvider _userProvider = Get.find<UserProvider>();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadChats();
    _setupRealtime();
  }

  void _loadChats() async {
    setState(() => _isLoading = true);
    try {
      final userId = _userProvider.currentUser['id'];
      if (userId != null) {
        final chats = await _chatService.fetchChats(userId);

        // Fetch additional data for each chat
        final enrichedChats = await Future.wait(
          chats.map((chat) async {
            final participants = List<String>.from(chat['participants'] ?? []);
            final otherUserId = participants.firstWhere(
              (id) => id != userId,
              orElse: () => '',
            );

            if (otherUserId.isNotEmpty) {
              final profile = await _chatService.fetchUserProfile(otherUserId);
              final lastMessage = await _chatService.fetchLastMessage(
                chat['id'],
              );

              return {
                ...chat,
                'otherUser': profile,
                'lastMessage': lastMessage,
              };
            }
            return chat;
          }),
        );

        setState(() {
          _chats = enrichedChats;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load chats: $e');
    }
  }

  void _setupRealtime() {
    final userId = _userProvider.currentUser['id'];
    if (userId != null) {
      _chatService.setupMessageRealtime(userId, _loadChats);
      _chatService.setupOnlineStatusRealtime(_loadChats);
    }
  }

  List<Map<String, dynamic>> get _filteredChats {
    if (_searchQuery.isEmpty) return _chats;
    return _chats.where((chat) {
      final userName = chat['otherUser']?['name']?.toLowerCase() ?? '';
      return userName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: EdgeInsets.all(12.sp),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.profile),
                      child: CircleAvatar(
                        radius: 18.sp,
                        backgroundImage: AssetImage(
                          _userProvider.currentUser['avatar'] ??
                              'assets/logo.png',
                        ),
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${_userProvider.currentUser['name'] ?? 'User'}!',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            'Have a great day!',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Iconsax.notification_bold, size: 20.sp),
                      onPressed: () => Get.toNamed(AppRoutes.notifications),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.sp),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    prefixIcon: Icon(Icons.search, size: 18.sp),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.sp),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.sp,
                      horizontal: 12.sp,
                    ),
                  ),
                ),
              ).animate().slideX(begin: -0.1, end: 0, duration: 600.ms),

              SizedBox(height: 15.sp),

              // Chat List
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredChats.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No Chats Yet'
                              : 'No chats found',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 12.sp),
                        itemCount: _filteredChats.length,
                        itemBuilder: (context, index) {
                          final chat = _filteredChats[index];
                          return _buildChatTile(chat, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Get.toNamed(AppRoutes.search), // Navigate to new chat screen
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ).animate().scale(duration: 500.ms, delay: 800.ms),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat, int index) {
    final otherUser = chat['otherUser'] as Map<String, dynamic>?;
    final lastMessage = chat['lastMessage'] as Map<String, dynamic>?;
    final isOnline = otherUser?['online_status'] ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: 8.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
      elevation: 2,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 20.sp,
              backgroundImage: otherUser?['avatar_url'] != null
                  ? CachedNetworkImageProvider(otherUser!['avatar_url'])
                  : const AssetImage('assets/logo.png') as ImageProvider,
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10.sp,
                  height: 10.sp,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5.sp),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          otherUser?['name'] ?? 'Unknown User',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          lastMessage?['content'] ?? 'No messages yet',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lastMessage?['timestamp'] != null
                  ? DateFormat(
                      'HH:mm',
                    ).format(DateTime.parse(lastMessage!['timestamp']))
                  : '',
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
          ],
        ),
        onTap: () =>
            Get.toNamed(AppRoutes.chatRoom, arguments: {'chatId': chat['id']}),
      ),
    ).animate().slideY(
      begin: 0.1,
      end: 0,
      duration: 400.ms,
      delay: Duration(milliseconds: index * 50),
    );
  }
}
