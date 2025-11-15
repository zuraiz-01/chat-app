import 'package:chat_app/services/call_service.dart';
import 'package:get/get.dart';

class CallProvider extends GetxController {
  final _callService = CallService();

  final RxList<Map<String, dynamic>> callLogs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCallActive = false.obs;
  final RxString callDuration = '0:00'.obs;

  // Load call logs
  Future<void> loadCallLogs(String userId) async {
    try {
      isLoading.value = true;
      final logs = await _callService.getCallLogs(userId);
      callLogs.value = logs;
    } catch (e) {
      print('Error loading call logs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Stream call logs
  Stream<List<Map<String, dynamic>>> streamCallLogs(String userId) {
    return _callService.getCallLogsStream(userId);
  }

  // Add call log
  Future<void> addCallLog({
    required String initiatorId,
    required String recipientId,
    required int duration,
    required String callType,
    required bool missed,
  }) async {
    try {
      await _callService.addCallLog(
        initiatorId: initiatorId,
        recipientId: recipientId,
        duration: duration,
        callType: callType,
        missed: missed,
      );
      await loadCallLogs(initiatorId);
    } catch (e) {
      print('Error adding call log: $e');
    }
  }

  // Format duration
  String formatDuration(int seconds) {
    return _callService.getFormattedDuration(seconds);
  }

  // Start call
  void startCall(String calleeId) {
    isCallActive.value = true;
  }

  // End call
  void endCall() {
    isCallActive.value = false;
    callDuration.value = '0:00';
  }

  // Update call duration (call periodically)
  void updateCallDuration(int seconds) {
    callDuration.value = formatDuration(seconds);
  }
}
