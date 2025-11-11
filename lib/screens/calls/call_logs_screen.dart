import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CallLogsScreen extends StatelessWidget {
  const CallLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calls', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Center(
        child: Text('Call Logs Screen', style: TextStyle(fontSize: 16.sp)),
      ),
    );
  }
}
