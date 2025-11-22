import 'package:chat_app/screens/home/home.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/service/auth_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  bool _isSupabaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkSupabaseInitialization();
  }

  // This function ensures Supabase is initialized.
  Future<void> _checkSupabaseInitialization() async {
    // Supabase is initialized in main.dart, just check if it's ready
    try {
      setState(() {
        _isSupabaseInitialized = true;
      });
    } catch (e) {
      // If still not initialized, wait and retry
      await Future.delayed(const Duration(milliseconds: 100));
      _checkSupabaseInitialization();
    }
  }

  @override
  Widget build(BuildContext context) {
    // If Supabase is still initializing, show the SplashScreen
    if (!_isSupabaseInitialized) {
      return const SplashScreen();
    }

    // Now we can safely access the current session.
    final session = _authService.getCurrentSession();

    if (session != null) {
      // If user has an active session, navigate to Home
      return const HomeTabScreen();
    }

    // If no session exists, show the login screen
    return const LoginScreen();
  }
}
