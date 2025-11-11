import 'package:chat_app/auth/auth_gate.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vfvvoxumctiaugtqfkbq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdnZveHVtY3RpYXVndHFma2JxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NzgxODAsImV4cCI6MjA3ODM1NDE4MH0.1WnKWMkfJRAKqKZsgGreOd3pMs0YOe6Xq8zpKH50sv8',
  );

  runApp(const QuickConnectApp());
}

class QuickConnectApp extends StatelessWidget {
  const QuickConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Quick Connect',
          theme: ThemeData(
            primaryColor: const Color(0xFF10451D),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Poppins',
          ),
          initialRoute: AppRoutes.home,
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
