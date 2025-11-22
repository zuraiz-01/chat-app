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

  // Local cache to avoid repeated DB hits
  final Map<String, Map<String, dynamic>?> _userCache = {};

  @override
  void initState() {
    super.initState();
    final user = _supabaseService.client!.auth.currentUser;
    _currentUserId = user?.id ?? '';
  }

  Future<Map<String, dynamic>?> _getUserCached(String chatId) async {
    if (_userCache.containsKey(chatId)) {
      return _userCache[chatId];
    }

    final user = await _supabaseService.getOtherParticipant(
      chatId,
      _currentUserId,
    );

    _userCache[chatId] = user;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Logs'), elevation: 0),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _callProvider.streamAllCallLogs(),
        builder: (context, snapshot) {
          // Loading state
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data ?? [];

          // No logs
          if (logs.isEmpty) {
            return const Center(child: Text('No call history yet'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              final bool isMissed = log['missed'] ?? false;
              final String callType = log['call_type'] ?? 'voice';
              final String userId = log['user_id'] ?? '';
              final bool isOutgoing = userId == _currentUserId;
              final String chatId = log['chat_id'] ?? '';
              final int duration = log['duration'] ?? 0;

              final timestamp =
                  DateTime.tryParse(log['created_at'] ?? '') ?? DateTime.now();

              final formattedTime = DateFormat(
                'dd MMM, hh:mm a',
              ).format(timestamp);

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserCached(chatId),
                builder: (context, userSnapshot) {
                  final otherUser = userSnapshot.data;

                  final otherUserName =
                      otherUser?['username'] ??
                      otherUser?['full_name'] ??
                      'Unknown';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isOutgoing
                          ? Colors.green.shade400
                          : Colors.blue.shade400,
                      child: Text(
                        otherUserName.isNotEmpty
                            ? otherUserName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    title: Text(
                      '${callType.toUpperCase()} Call'
                      '${isMissed ? ' (Missed)' : ''}',
                    ),

                    subtitle: Text(
                      '${isOutgoing ? 'Outgoing' : 'Incoming'} • $otherUserName\n'
                      'Duration: ${duration}s • $formattedTime',
                    ),
                    isThreeLine: true,

                    trailing: Icon(
                      callType == 'video' ? Icons.videocam : Icons.call,
                      color: isMissed
                          ? Colors.red
                          : (isOutgoing ? Colors.green : Colors.blue),
                    ),
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
