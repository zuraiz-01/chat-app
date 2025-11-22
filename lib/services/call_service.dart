import 'package:chat_app/services/supabase_service.dart';
import 'package:get/get.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  final _supabaseService = SupabaseService();

  factory CallService() {
    return _instance;
  }

  CallService._internal();

  // Add call log (NEW APPROACH)
  Future<void> addCallLog({
    required String chatId,
    required String userId,
    required int duration,
    required String callType,
    required bool missed,
  }) async {
    try {
      await _supabaseService.addCallLog(
        chatId: chatId,
        userId: userId,
        duration: duration,
        callType: callType,
        missed: missed,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save call log: $e');
      rethrow;
    }
  }

  // Get logs by chatId
  Future<List<Map<String, dynamic>>> getCallLogs(String chatId) async {
    try {
      return await _supabaseService.getCallLogs(chatId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load call logs: $e');
      rethrow;
    }
  }

  // Stream logs by chatId
  Stream<List<Map<String, dynamic>>> getCallLogsStream(String chatId) {
    return _supabaseService.getCallLogsStream(chatId);
  }

  // Stream all call logs for the user
  Stream<List<Map<String, dynamic>>> getAllCallLogsStream() {
    return _supabaseService.getAllCallLogsStream();
  }

  // Duration calculator
  int calculateDuration(DateTime startTime, DateTime endTime) {
    return endTime.difference(startTime).inSeconds;
  }

  // Format seconds as text
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
