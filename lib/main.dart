// ignore_for_file: avoid_print, use_super_parameters

import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/providers/call_provider.dart';
import 'package:chat_app/providers/friend_provider.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/core/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ FIRST: Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    if (!AppConfig.validate()) {
      throw Exception('Missing required environment variables');
    }
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('❌ Failed to load environment variables: $e');
    // In production, you might want to show an error screen
  }

  // ⭐ SECOND: Initialize Supabase with env variables
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize Supabase: $e');
    // In production, show error screen
  }

  // ⭐ THIRD: Initialize GetX Controllers
  Get.put(AuthService(), permanent: true);
  Get.put(UserProvider(), permanent: true);
  Get.put(ChatProvider(), permanent: true);
  Get.put(CallProvider(), permanent: true);
  Get.put(FriendProvider(), permanent: true);

  // ⭐ LAST: Start App
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Chat App',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: Colors.blue,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
          ),
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.onboarding,
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
