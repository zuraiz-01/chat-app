import 'package:flutter/material.dart';
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
        child: const Center(child: Text('No groups yet')),
      ),
    );
  }
}
