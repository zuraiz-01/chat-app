import 'package:chat_app/screens/home/home.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    // We check if Supabase is initialized correctly here
    if (Supabase.instance.client == null) {
      // If not, wait until it's done initializing.
      await Supabase.initialize(
        url: 'https://vfvvoxumctiaugtqfkbq.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdnZveHVtY3RpYXVndHFma2JxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NzgxODAsImV4cCI6MjA3ODM1NDE4MH0.1WnKWMkfJRAKqKZsgGreOd3pMs0YOe6Xq8zpKH50sv8',
      );
    }
    setState(() {
      _isSupabaseInitialized = true;
    });
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
