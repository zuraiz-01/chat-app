import 'package:chat_app/screens/calls/call_logs_screen.dart';
import 'package:chat_app/screens/chat/chat_list_screen.dart';
import 'package:chat_app/screens/chat/group_chat_screen.dart';
import 'package:chat_app/screens/friends/friends_screen.dart';
import 'package:chat_app/screens/groups/groups_screen.dart';
import 'package:chat_app/screens/home/home.dart';
import 'package:chat_app/screens/notifications/notifications_screen.dart';
import 'package:chat_app/screens/profile/other_profile_screen.dart';
import 'package:chat_app/screens/profile/profile_screen.dart';
import 'package:chat_app/screens/chat/chat_room_screen.dart';
import 'package:chat_app/screens/search/search_screen.dart';
import 'package:chat_app/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String home = '/';
  static const String chatList = '/chatList';
  static const String friends = '/friends';
  static const String calls = '/calls';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String chatRoom = '/chatRoom';
  static const String groupChat = '/groupChat/:groupId';
  static const String groups = '/groups';
  static const String otherProfile = '/otherProfile/:userId';

  static final routes = [
    GetPage(name: home, page: () => const homeScreen()),
    GetPage(name: chatList, page: () => const ChatListScreen()),
    GetPage(name: friends, page: () => const FriendsScreen()),
    GetPage(name: calls, page: () => const CallLogsScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: notifications, page: () => const NotificationsScreen()),
    GetPage(name: search, page: () => const SearchScreen()),
    GetPage(name: chatRoom, page: () => const ChatRoomScreen()),
    GetPage(
      name: groupChat,
      page: () => GroupChatScreen(groupId: Get.parameters['groupId']!),
    ),
    GetPage(name: groups, page: () => const GroupsScreen()),
    GetPage(
      name: otherProfile,
      page: () => OtherProfileScreen(userId: Get.parameters['userId']!),
    ),
  ];
}
