import 'package:chat_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsOptions = [
      {
        'icon': Icons.person_outline_rounded,
        'title': 'Account',
        'subtitle': 'Privacy, security, change number',
        'onTap': () => Get.toNamed(AppRoutes.account),
      },
      {
        'icon': Icons.chat_outlined,
        'title': 'Chats',
        'subtitle': 'Theme, wallpapers, chat history',
        'onTap': () {
          Get.toNamed(AppRoutes.chatSettings);
        },
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'subtitle': 'Message, group & call tones',
        'onTap': () {
          Get.toNamed(AppRoutes.notificationsSettings);
        },
      },
      {
        'icon': Icons.lock_outline_rounded,
        'title': 'Privacy',
        'subtitle': 'Last seen, profile photo, blocked contacts',
        'onTap': () {
          Get.toNamed(AppRoutes.privacy);
        },
      },
      {
        'icon': Icons.color_lens_outlined,
        'title': 'Appearance',
        'subtitle': 'Dark mode, font size, theme color',
        'onTap': () {
          Get.toNamed(AppRoutes.appearance);
        },
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Help',
        'subtitle': 'FAQ, contact us, app info',
        'onTap': () {
          Get.toNamed(AppRoutes.help);
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: settingsOptions.length + 1,
        separatorBuilder: (_, __) => Divider(thickness: 0.2, height: 1.h),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Top Profile Section
            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Hero(
                  tag:
                      'profile_avatar_settings', // Unique tag for the avatar in settings
                  child: CircleAvatar(
                    radius: 22.sp,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/150?img=7',
                    ),
                  ),
                ),
                title: Text(
                  'Zuraiz Ahmed',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Hey there! I am using ChatApp.',
                  style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.profile);
                },
              ),
            );
          }

          final setting = settingsOptions[index - 1];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(setting['icon'], size: 22.sp, color: Colors.blueGrey),
            title: Text(
              setting['title'],
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              setting['subtitle'],
              style: TextStyle(fontSize: 15.sp, color: Colors.grey),
            ),
            onTap: setting['onTap'],
          );
        },
      ),
    );
  }
}
