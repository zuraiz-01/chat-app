import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ChatSettingsScreen extends StatelessWidget {
  const ChatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Settings', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'Enter key sends message',
                style: TextStyle(fontSize: 17.sp),
              ),
              value: true,
              onChanged: (val) {},
            ),
            ListTile(
              leading: const Icon(Icons.wallpaper_rounded),
              title: Text('Chat Wallpaper', style: TextStyle(fontSize: 17.sp)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text('Chat Backup', style: TextStyle(fontSize: 17.sp)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
