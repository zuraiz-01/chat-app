import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_rounded),
              title: Text('Change Number', style: TextStyle(fontSize: 17.sp)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock_rounded),
              title: Text(
                'Privacy & Security',
                style: TextStyle(fontSize: 17.sp),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(
                'Delete My Account',
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
