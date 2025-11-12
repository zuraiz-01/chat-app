import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CallLogsScreen extends StatelessWidget {
  const CallLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> callLogs = [
      {
        'name': 'Ali Khan',
        'time': 'Today, 10:45 AM',
        'type': 'incoming',
        'avatar': 'https://i.pravatar.cc/150?img=1',
      },
      {
        'name': 'Sara Ahmed',
        'time': 'Yesterday, 9:20 PM',
        'type': 'outgoing',
        'avatar': 'https://i.pravatar.cc/150?img=2',
      },
      {
        'name': 'Hassan Raza',
        'time': 'Yesterday, 5:10 PM',
        'type': 'missed',
        'avatar': 'https://i.pravatar.cc/150?img=3',
      },
      {
        'name': 'Fatima Noor',
        'time': '2 days ago, 8:05 PM',
        'type': 'incoming',
        'avatar': 'https://i.pravatar.cc/150?img=4',
      },
    ];

    IconData _getCallIcon(String type) {
      switch (type) {
        case 'incoming':
          return Icons.call_received_rounded;
        case 'outgoing':
          return Icons.call_made_rounded;
        case 'missed':
          return Icons.call_missed_rounded;
        default:
          return Icons.call_rounded;
      }
    }

    Color _getCallColor(String type) {
      switch (type) {
        case 'incoming':
          return Colors.green;
        case 'outgoing':
          return Colors.blue;
        case 'missed':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Calls', style: TextStyle(fontSize: 18.sp)),
        toolbarHeight: 60.sp,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: ListView.builder(
          itemCount: callLogs.length,
          itemBuilder: (context, index) {
            final call = callLogs[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 20.sp,
                backgroundImage: NetworkImage(call['avatar']),
              ),
              title: Text(
                call['name'],
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500),
              ),
              subtitle: Row(
                children: [
                  Icon(
                    _getCallIcon(call['type']),
                    color: _getCallColor(call['type']),
                    size: 16.sp,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    call['time'],
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.phone_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
                onPressed: () {
                  // TODO: integrate call functionality
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: start new call
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }
}
