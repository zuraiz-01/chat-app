import 'package:chat_app/screens/home/home.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 🟢 Login with Email/Password
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar('Error', 'Email and password cannot be empty.');
        return;
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        Get.snackbar('Login Failed', 'Invalid email or password.');
        return;
      }

      Get.snackbar('Success', 'Logged in successfully!');

      Get.offAll(() => const HomeTabScreen());
    } on AuthException catch (e) {
      Get.snackbar('Auth Error', e.message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // 🟣 Signup with Email/Password
  Future<void> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        Get.snackbar('Error', 'All fields are required.');
        return;
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        Get.snackbar('Sign Up Failed', 'Something went wrong. Try again.');
        return;
      }

      // Insert profile into database
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'username': name.toLowerCase().replaceAll(' ', '_'),
        'full_name': name,
      });

      Get.snackbar('Success', 'Account created successfully!');
    } on AuthException catch (e) {
      Get.snackbar('Auth Error', e.message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // 🔵 Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://vfvvoxumctiaugtqfkbq.supabase.co/auth/v1/callback',
      );
    } catch (e) {
      Get.snackbar('Google Sign-In Failed', e.toString());
    }
  }

  // 🔴 Logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      Get.snackbar('Signed Out', 'You have been logged out.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // 🟡 Current User Email
  String? getCurrentUserEmail() {
    final user = _supabase.auth.currentUser;
    return user?.email;
  }

  // 🟠 Get Current Session
  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  // 🔵 Reset Password
  Future<void> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        Get.snackbar('Error', 'Email cannot be empty.');
        return;
      }

      await _supabase.auth.resetPasswordForEmail(email);
      Get.snackbar('Success', 'Password reset link sent to your email.');
    } on AuthException catch (e) {
      Get.snackbar('Auth Error', e.message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
