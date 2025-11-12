import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Settings', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_rounded),
              title: Text(
                'Last Seen & Online',
                style: TextStyle(fontSize: 17.sp),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('Profile Photo', style: TextStyle(fontSize: 17.sp)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded),
              title: Text(
                'Blocked Contacts',
                style: TextStyle(fontSize: 17.sp),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
