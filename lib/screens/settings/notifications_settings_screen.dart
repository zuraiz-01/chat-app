import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:get/get.dart';

class NotificationsSettingsScreen extends StatelessWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: ListView.separated(
          itemCount: 3, // Number of notification settings
          separatorBuilder: (_, __) => Divider(thickness: 0.2, height: 1.h),
          itemBuilder: (context, index) {
            if (index == 0) {
              return SwitchListTile(
                title: Text(
                  'Message Notifications',
                  style: TextStyle(fontSize: 17.sp),
                ),
                value: true, // Replace with actual state management
                onChanged: (val) {},
                activeColor: Get.theme.primaryColor,
                inactiveThumbColor: Colors.grey,
              );
            } else if (index == 1) {
              return SwitchListTile(
                title: Text(
                  'Group Notifications',
                  style: TextStyle(fontSize: 17.sp),
                ),
                value: false, // Replace with actual state management
                onChanged: (val) {},
                activeColor: Get.theme.primaryColor,
                inactiveThumbColor: Colors.grey,
              );
            } else {
              return SwitchListTile(
                title: Text(
                  'Call Notifications',
                  style: TextStyle(fontSize: 17.sp),
                ),
                value: true, // Replace with actual state management
                onChanged: (val) {},
                activeColor: Get.theme.primaryColor,
                inactiveThumbColor: Colors.grey,
              );
            }
          },
        ),
      ),
    );
  }
}
