import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    try {
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar("Error", "Email and password cannot be empty.");
        return;
      }

      final supabase = this.supabase;
      if (supabase == null) {
        Get.snackbar("Error", "Supabase not initialized");
        return;
      }

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        Get.snackbar("Login Failed", "Invalid email or password.");
        return;
      }

      Get.snackbar("Success", "Logged in successfully!");
      Get.offAll(() => const HomeTabScreen());
    } on AuthException catch (e) {
      Get.snackbar("Auth Error", e.message);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // 🟣 Sign Up With Email/Password
  Future<void> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        Get.snackbar("Error", "All fields are required.");
        return;
      }

      final supabase = this.supabase;
      if (supabase == null) {
        Get.snackbar("Error", "Supabase not initialized");
        return;
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        Get.snackbar("Sign Up Failed", "Something went wrong.");
        return;
      }

      await supabase.from("profiles").insert({
        "id": response.user!.id,
        "username": name.toLowerCase().replaceAll(" ", "_"),
        "full_name": name,
      });

      Get.snackbar("Success", "Account created successfully!");
    } on AuthException catch (e) {
      Get.snackbar("Auth Error", e.message);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // 🔵 Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      final supabase = this.supabase;
      if (supabase == null) {
        Get.snackbar("Error", "Supabase not initialized");
        return;
      }

      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: "https://vfvvoxumctiaugtqfkbq.supabase.co/auth/v1/callback",
      );
    } catch (e) {
      Get.snackbar("Google Sign-In Failed", e.toString());
    }
  }

  // 🔴 Logout
  Future<void> signOut() async {
    try {
      final supabase = this.supabase;
      if (supabase == null) {
        Get.snackbar("Error", "Supabase not initialized");
        return;
      }

      await supabase.auth.signOut();
      Get.snackbar("Signed Out", "You have been logged out.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
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
