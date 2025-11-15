import 'package:chat_app/services/supabase_service.dart';
import 'package:get/get.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  final _supabaseService = SupabaseService();

  factory CallService() {
    return _instance;
  }

  CallService._internal();

  // Add call log
  Future<void> addCallLog({
    required String initiatorId,
    required String recipientId,
    required int duration,
    required String callType,
    required bool missed,
  }) async {
    try {
      await _supabaseService.addCallLog(
        initiatorId: initiatorId,
        recipientId: recipientId,
        duration: duration,
        callType: callType,
        missed: missed,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save call log: $e');
      rethrow;
    }
  }

  // Get call logs
  Future<List<Map<String, dynamic>>> getCallLogs(String userId) async {
    try {
      return await _supabaseService.getCallLogs(userId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load call logs: $e');
      rethrow;
    }
  }

  // Stream call logs
  Stream<List<Map<String, dynamic>>> getCallLogsStream(String userId) {
    return _supabaseService.getCallLogsStream(userId);
  }

  // Calculate call duration
  int calculateDuration(DateTime startTime, DateTime endTime) {
    return endTime.difference(startTime).inSeconds;
  }

  // Get call duration formatted
  String getFormattedDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else if (minutes > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    } else {
      return '0:${secs.toString().padLeft(2, '0')}';
    }
  }
}
