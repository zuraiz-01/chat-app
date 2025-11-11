import 'package:chat_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(12.sp),
          itemCount: 5, // Mock chats
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.only(bottom: 6.sp),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.sp),
              ),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 18.sp,
                  backgroundImage: const AssetImage('assets/logo.png'),
                ),
                title: Text(
                  'Friend ${index + 1}',
                  style: TextStyle(fontSize: 14.sp),
                ),
                subtitle: Text(
                  'Last message... ${DateTime.now().hour}:${DateTime.now().minute}',
                  style: TextStyle(fontSize: 12.sp),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14.sp),
                onTap: () => Get.toNamed(AppRoutes.chatRoom),
              ),
            ).animate().fadeIn(
              duration: 300.ms,
              delay: Duration(milliseconds: index * 100),
            );
          },
        ),
      ),
    );
  }
}
