import 'package:chat_app/screens/auth/forgot_password_screen.dart';
import 'package:chat_app/screens/auth/signup_screen.dart';
import 'package:chat_app/screens/home/home.dart';
import 'package:chat_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();
  late bool _obscurePassword;

  @override
  void initState() {
    super.initState();
    _obscurePassword = true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF10451D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Image.asset(
                  'assets/logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),

                // App name
                Text(
                  'Quick Connect',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect. Share. Chat.',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),

                const SizedBox(height: 50),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password
                StatefulBuilder(
                  builder: (context, setState) {
                    return TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => const ForgotPasswordScreen());
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      Get.snackbar('Error', 'Email and password required');
                      return;
                    }

                    try {
                      await _supabaseService.signIn(
                        email: email,
                        password: password,
                      );
                      Get.offAll(() => const HomeTabScreen());
                    } catch (e) {
                      Get.snackbar('Login Error', e.toString());
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey.shade300),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or"),
                    ),
                    Expanded(
                      child: Divider(thickness: 1, color: Colors.grey.shade300),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Google Sign-In Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  onPressed: () {
                    Get.snackbar(
                      'Coming Soon',
                      'Google sign-in will be available soon',
                    );
                  },
                  icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                  label: Text(
                    "Sign in with Google",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Signup link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const SignupScreen());
                      },
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
