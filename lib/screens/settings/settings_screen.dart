import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Center(
        child: Text('Settings Screen', style: TextStyle(fontSize: 16.sp)),
      ),
    );
  }
}
