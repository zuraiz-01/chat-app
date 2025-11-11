import 'package:chat_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups', style: TextStyle(fontSize: 18.sp)),
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
          itemCount: 5, // Mock groups
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.only(bottom: 6.sp),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.sp),
              ),
              elevation: 2,
              child: ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 18.sp,
                      backgroundImage: const AssetImage('assets/logo.png'),
                    ),
                    if (index % 2 == 0) // Mock stacked avatar
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 8.sp,
                          backgroundImage: const AssetImage('assets/logo.png'),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  'Group ${index + 1}',
                  style: TextStyle(fontSize: 14.sp),
                ),
                subtitle: Text(
                  'Last message... ${DateTime.now().hour}:${DateTime.now().minute}',
                  style: TextStyle(fontSize: 12.sp),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(index + 1) * 3} members',
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14.sp),
                  ],
                ),
                onTap: () => Get.toNamed('/groupChat/group${index + 1}'),
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
