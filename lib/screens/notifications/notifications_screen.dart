import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Center(
        child: Text('Notifications Screen', style: TextStyle(fontSize: 16.sp)),
      ),
    );
  }
}
