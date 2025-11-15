import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/screens/splash/onboarding_screen.dart';
import 'package:chat_app/screens/splash/splash_screen.dart';
import 'package:chat_app/providers/user_provider.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/providers/call_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://vfvvoxumctiaugtqfkbq.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdnZveHVtY3RpYXVndHFma2JxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NzgxODAsImV4cCI6MjA3ODM1NDE4MH0.1WnKWMkfJRAKqKZsgGreOd3pMs0YOe6Xq8zpKH50sv8',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Supabase: $e');
  }

  // Initialize GetX Controllers
  Get.put(UserProvider(), permanent: true);
  Get.put(ChatProvider(), permanent: true);
  Get.put(CallProvider(), permanent: true);

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
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            textTheme: const TextTheme(
              headlineSmall: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
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
