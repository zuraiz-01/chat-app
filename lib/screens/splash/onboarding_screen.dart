import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _controller,
            children: const [
              OnboardPage(
                title: "Connect Instantly",
                subtitle: "Chat with anyone, anytime with lightning speed.",
                icon: EvaIcons.paper_plane_outline,
              ),
              OnboardPage(
                title: "Share Moments",
                subtitle: "Send photos, videos, and memories easily.",
                icon: EvaIcons.camera_outline,
              ),
              OnboardPage(
                title: "We are the Best Chat App",
                subtitle: "Experience seamless chatting like never before.",
                icon: EvaIcons.message_circle_outline,
                showButton: true,
              ),
            ],
          ),
          // Page indicator
          Positioned(
            bottom: 40,
            child: SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: ExpandingDotsEffect(
                activeDotColor: const Color(0xFF10451D),
                dotColor: Colors.grey.shade400,
                dotHeight: 10,
                dotWidth: 10,
                spacing: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool showButton;

  const OnboardPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.showButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: const Color(0xFF10451D)),
          const SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10451D),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          if (showButton) ...[
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10451D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
              ),
              onPressed: () {
                Get.offAll(() => const LoginScreen());
              },
              child: const Text(
                "Start Chatting",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
