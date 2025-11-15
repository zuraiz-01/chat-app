import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/screens/calls/call_logs_screen.dart';
import 'package:chat_app/screens/chat/chat_list_screen.dart';
import 'package:chat_app/screens/friends/friends_screen.dart';
import 'package:chat_app/screens/groups/groups_screen.dart';
import 'package:chat_app/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:icons_plus/icons_plus.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ChatListScreen(), // Chats
    const GroupsScreen(), // Groups
    const CallLogsScreen(), // Calls
    const FriendsScreen(), // Friends
    const SettingsScreen(), // Settings
  ];

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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF10451D),
        unselectedItemColor: Colors.grey,
        iconSize: 20.sp,
        selectedFontSize: 14.sp,
        unselectedFontSize: 12.sp,
        items: const [
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
      ),
      floatingActionButton:
          _selectedIndex ==
              0 // Only show on Chats tab
          ? FloatingActionButton(
              heroTag: 'homeFab',
              onPressed: () => Get.toNamed(AppRoutes.search),
              child: Icon(Iconsax.add_bold, size: 20.sp),
            )
          : null,
    );
  }
}
