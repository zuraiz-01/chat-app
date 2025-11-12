import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Appearance', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Dark Mode', style: TextStyle(fontSize: 17.sp)),
              value: isDarkMode,
              onChanged: (val) {},
            ),
            ListTile(
              leading: const Icon(Icons.format_size_rounded),
              title: Text('Font Size', style: TextStyle(fontSize: 17.sp)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.color_lens_outlined),
              title: Text('Theme Color', style: TextStyle(fontSize: 17.sp)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
