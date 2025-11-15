import 'package:chat_app/screens/auth/forgot_password_screen.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/auth/signup_screen.dart';
import 'package:chat_app/screens/calls/call_logs_screen.dart';
import 'package:chat_app/screens/chat/chat_list_screen.dart';
import 'package:chat_app/screens/chat/chat_room_screen.dart';
import 'package:chat_app/screens/chat/group_chat_screen.dart';
import 'package:chat_app/screens/friends/friends_screen.dart';
import 'package:chat_app/screens/groups/groups_screen.dart';
import 'package:chat_app/screens/home/home.dart';
import 'package:chat_app/screens/notifications/notifications_screen.dart';
import 'package:chat_app/screens/profile/other_profile_screen.dart';
import 'package:chat_app/screens/profile/profile_screen.dart';
import 'package:chat_app/screens/search/search_screen.dart';
import 'package:chat_app/screens/settings/account_settings_screen.dart';
import 'package:chat_app/screens/settings/appearance_settings_screen.dart';
import 'package:chat_app/screens/settings/chat_settings_screen.dart';
import 'package:chat_app/screens/settings/help_screen.dart';
import 'package:chat_app/screens/settings/notifications_settings_screen.dart';
import 'package:chat_app/screens/settings/privacy_settings_screen.dart';
import 'package:chat_app/screens/settings/settings_screen.dart';
import 'package:chat_app/screens/splash/onboarding_screen.dart';
import 'package:chat_app/screens/splash/splash_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  // 🌐 Route Names
  static const String splash = '/';
  static const String home = '/home';
  static const String chatList = '/chatList';
  static const String friends = '/friends';
  static const String groups = '/groups';
  static const String calls = '/calls';
  static const String chatRoom = '/chatRoom';
  static const String groupChat = '/groupChat/:groupId';
  static const String profile = '/profile';
  static const String otherProfile = '/otherProfile/:userId';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String settings = '/settings';

  // ⚙️ Settings Subpages
  static const String privacy = '/privacy';
  static const String appearance = '/appearance';
  static const String help = '/help';
  static const String account = '/account';
  static const String chatSettings = '/chatSettings';
  static const String notificationsSettings = '/notificationsSettings';
  static const String chatlist = '/chatlist';

  // 🔐 Auth Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgotPassword';
  static const String onboarding = '/onboarding';

  // 📄 Route Definitions
  static final routes = [
    // 🟦 Splash
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),

    // 🏠 Main App
    GetPage(name: home, page: () => const HomeTabScreen()),
    GetPage(name: chatList, page: () => const ChatListScreen()),
    GetPage(name: friends, page: () => const FriendsScreen()),
    GetPage(name: groups, page: () => const GroupsScreen()),
    GetPage(name: calls, page: () => const CallLogsScreen()),

    // 💬 Chat
    GetPage(
      name: chatRoom,
      page: () => ChatRoomScreen(
        chatId: Get.parameters['chatId'] ?? '',
        otherUserId: Get.parameters['otherUserId'] ?? '',
        otherUserName: Get.parameters['otherUserName'] ?? 'Unknown',
        isVideoCall: Get.parameters['isVideoCall'] == 'true',
      ),
    ),
    GetPage(
      name: groupChat,
      page: () => GroupChatScreen(groupId: Get.parameters['groupId']!),
    ),

    // 👤 Profile
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(
      name: otherProfile,
      page: () => OtherProfileScreen(userId: Get.parameters['userId']!),
    ),

    // 🔔 Notifications & Search
    GetPage(name: notifications, page: () => const NotificationsScreen()),
    GetPage(name: search, page: () => const SearchScreen()),
    GetPage(name: chatList, page: () => const ChatListScreen()),

    // ⚙️ Settings
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: privacy, page: () => const PrivacySettingsScreen()),
    GetPage(name: appearance, page: () => const AppearanceSettingsScreen()),
    GetPage(name: help, page: () => const HelpScreen()),
    GetPage(name: account, page: () => const AccountSettingsScreen()),
    GetPage(name: chatSettings, page: () => const ChatSettingsScreen()),
    GetPage(
      name: notificationsSettings,
      page: () => const NotificationsSettingsScreen(),
    ),

    // 🔐 Auth Screens
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
  ];
}
