import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.help_outline_rounded),
              title: Text('FAQs', style: TextStyle(fontSize: 17.sp)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text('Contact Us', style: TextStyle(fontSize: 17.sp)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text('App Info', style: TextStyle(fontSize: 17.sp)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

