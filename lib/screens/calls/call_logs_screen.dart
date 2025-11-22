// ignore_for_file: sort_child_properties_last

import 'package:chat_app/providers/call_provider.dart';
import 'package:chat_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CallLogsScreen extends StatefulWidget {
  const CallLogsScreen({Key? key}) : super(key: key);

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  final CallProvider _callProvider = Get.find<CallProvider>();
  final SupabaseService _supabaseService = SupabaseService();
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    final user = _supabaseService.client?.auth.currentUser;
    _currentUserId = user?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Logs'), elevation: 0),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _callProvider.streamAllCallLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const Center(child: Text('No call history yet'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final isMissed = log['missed'] ?? false;
              final callType = log['call_type'] ?? 'voice';
              final userId = log['user_id'] ?? '';
              final isOutgoing = userId == _currentUserId;
              final chatId = log['chat_id'] ?? '';
              final duration = log['duration'] ?? 0;
              final timestamp =
                  DateTime.tryParse(log['created_at'] ?? '') ?? DateTime.now();
              final formattedTime = DateFormat(
                'dd MMM, hh:mm a',
              ).format(timestamp);

              return FutureBuilder<Map<String, dynamic>?>(
                future: _supabaseService.getOtherParticipant(
                  chatId,
                  _currentUserId,
                ),
                builder: (context, userSnapshot) {
                  final otherUser = userSnapshot.data;
                  final otherUserName =
                      otherUser?['username'] ??
                      otherUser?['full_name'] ??
                      'Unknown';

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        otherUserName.isNotEmpty
                            ? otherUserName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: isOutgoing
                          ? Colors.green.shade400
                          : Colors.blue.shade400,
                    ),
                    title: Text(
                      '${callType.toUpperCase()} Call' +
                          (isMissed ? ' (Missed)' : ''),
                    ),
                    subtitle: Text(
                      '${isOutgoing ? 'Outgoing' : 'Incoming'} • $otherUserName\nDuration: ${duration}s • $formattedTime',
                    ),
                    isThreeLine: true,
                    trailing: Icon(
                      callType == 'video' ? Icons.videocam : Icons.call,
                      color: isMissed
                          ? Colors.red
                          : (isOutgoing ? Colors.green : Colors.blue),
                    ),
                    onTap: () {
                      // Optionally open the call or chat screen
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
