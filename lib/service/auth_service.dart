import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/error_handler.dart';
import '../screens/home/home.dart';

class AuthService extends GetxService {
  // 🔵 Safe Supabase Client Getter
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (e) {
      return null;
    }
  }

  // Public getter for safe access
  SupabaseClient? get supabase => _supabase;

  // 🟢 Login with Email & Password
  Future<void> signInWithEmailPassword(String email, String password) async {
    final errorHandler = ErrorHandler();

    try {
      errorHandler.validateInput(email, 'Email');
      errorHandler.validateInput(password, 'Password', minLength: 6);

      final supabase = this.supabase;
      if (supabase == null) {
        throw Exception('Supabase not initialized');
      }

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Invalid email or password');
      }

      Get.snackbar("Success", "Logged in successfully!");
      Get.offAll(() => const HomeTabScreen());
    } catch (e) {
      errorHandler.handleError(e, customMessage: 'Login failed');
    }
  }

  // 🟣 Sign Up With Email/Password
  Future<void> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    final errorHandler = ErrorHandler();

    try {
      errorHandler.validateInput(email, 'Email');
      errorHandler.validateInput(password, 'Password', minLength: 6);
      errorHandler.validateInput(name, 'Name', minLength: 2);

      final supabase = this.supabase;
      if (supabase == null) {
        throw Exception('Supabase not initialized');
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      await supabase.from("profiles").insert({
        "id": response.user!.id,
        "username": name.toLowerCase().replaceAll(" ", "_"),
        "full_name": name,
      });

      Get.snackbar("Success", "Account created successfully!");
    } catch (e) {
      errorHandler.handleError(e, customMessage: 'Sign up failed');
    }
  }

  // 🔵 Google Sign-In
  Future<void> signInWithGoogle() async {
    final errorHandler = ErrorHandler();

    try {
      final supabase = this.supabase;
      if (supabase == null) {
        throw Exception('Supabase not initialized');
      }

      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: "${dotenv.env['SUPABASE_URL']}/auth/v1/callback",
      );
    } catch (e) {
      errorHandler.handleError(e, customMessage: 'Google sign-in failed');
    }
  }

  // 🔴 Logout
  Future<void> signOut() async {
    final errorHandler = ErrorHandler();

    try {
      final supabase = this.supabase;
      if (supabase == null) {
        throw Exception('Supabase not initialized');
      }

      await supabase.auth.signOut();
      Get.snackbar("Signed Out", "You have been logged out.");
    } catch (e) {
      errorHandler.handleError(e, customMessage: 'Sign out failed');
    }
  }

  // 🟡 Get Current User Email
  String? getCurrentUserEmail() {
    final supabase = this.supabase;
    return supabase?.auth.currentUser?.email;
  }

  // 🟠 Get Current Session
  Session? getCurrentSession() {
    final supabase = this.supabase;
    return supabase?.auth.currentSession;
  }

  // 🔵 Reset Password
  Future<void> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        Get.snackbar("Error", "Email cannot be empty.");
        return;
      }

      final supabase = this.supabase;
      if (supabase == null) {
        Get.snackbar("Error", "Supabase not initialized");
        return;
      }

      await supabase.auth.resetPasswordForEmail(email);

      Get.snackbar("Success", "Password reset link sent!");
    } on AuthException catch (e) {
      Get.snackbar("Auth Error", e.message);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
