import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/screens/calls/call_logs_screen.dart';
import 'package:chat_app/screens/chat/chat_list_screen.dart';
import 'package:chat_app/screens/friends/friends_screen.dart';
import 'package:chat_app/screens/groups/groups_screen.dart';
import 'package:chat_app/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ChatListScreen(),
    const GroupsScreen(),
    const CallLogsScreen(),
    const FriendsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0; // Ensure starts at Home
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Iconsax.home_bold), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message_bold),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.people_bold),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.call_bold),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user_bold),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.setting_bold),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF10451D),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        iconSize: 20.sp,
        selectedFontSize: 14.sp,
        unselectedFontSize: 12.sp,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👇 Top Bar
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.profile),
                        child: CircleAvatar(
                          radius: 18.sp,
                          backgroundImage: const AssetImage('assets/logo.png'),
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, User!',
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

                // 👇 Search Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search friends, chats...',
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
                    onTap: () => Get.toNamed(AppRoutes.search),
                  ),
                ).animate().slideX(begin: -0.1, end: 0, duration: 600.ms),

                SizedBox(height: 15.sp),

                // 👇 Active Friends Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Text(
                    'Active Friends',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 8.sp),
                SizedBox(
                  height: 45.sp,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12.sp),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 10.sp),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 25.sp,
                                  backgroundImage: const AssetImage(
                                    'assets/logo.png',
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 10.sp,
                                    height: 10.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3.sp),
                            Text(
                              'Friend ${index + 1}',
                              style: TextStyle(fontSize: 10.sp),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ).animate().slideX(begin: 0.1, end: 0, duration: 700.ms),

                SizedBox(height: 15.sp),

                // 👇 Recent Chats Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp),
                  child: Text(
                    'Recent Chats',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 8.sp),
                ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 12.sp),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.only(bottom: 6.sp),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 18.sp,
                              backgroundImage: const AssetImage(
                                'assets/logo.png',
                              ),
                            ),
                            title: Text(
                              'Chat ${index + 1}',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            subtitle: Text(
                              'Last message... ${DateTime.now().hour}:${DateTime.now().minute}',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 14.sp,
                            ),
                            onTap: index == 0
                                ? () => Get.toNamed('/groupChat/testGroupId')
                                : () => Get.toNamed(AppRoutes.chatList),
                          ),
                        );
                      },
                    )
                    // 👇 Correct animation chain placement
                    .animate()
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      duration: 800.ms,
                      delay: 200.ms,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
