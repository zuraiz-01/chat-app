import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/home/home.dart';
import 'package:chat_app/screens/splash/splash_screen.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  final Color primaryColor = const Color(0xFF10451D);
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    final session = _authService.getCurrentSession();

    // 🔹 If already logged in, go to Home
    if (session != null) {
      return const homeScreen();
    }

    // 🔹 Otherwise, listen for auth state changes
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading while waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: primaryColor)),
          );
        }

        final session = snapshot.data?.session;

        // If session is active → go Home
        if (session != null) {
          return const homeScreen();
        }

        // Else → go to Login screen
        return const LoginScreen();
      },
    );
  }
}
