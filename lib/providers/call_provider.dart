import 'package:chat_app/services/call_service.dart';
import 'package:get/get.dart';
import '../core/error_handler.dart';

class CallProvider extends GetxController {
  final _callService = CallService();

  final RxList<Map<String, dynamic>> callLogs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCallActive = false.obs;
  final RxString callDuration = '0:00'.obs;

  /// Load call logs (non-stream version)
  Future<void> loadCallLogs(String chatId) async {
    final errorHandler = ErrorHandler();

    try {
      isLoading.value = true;
      final logs = await _callService.getCallLogs(chatId);
      callLogs.assignAll(logs);
    } catch (e) {
      errorHandler.handleError(e, customMessage: 'Failed to load call logs');
    } finally {
      isLoading.value = false;
    }
  }

  /// Real-time stream: logs for a specific chat
  Stream<List<Map<String, dynamic>>> streamCallLogs(String chatId) {
    return _callService.getCallLogsStream(chatId);
  }

  /// Real-time stream: all call logs for current user
  Stream<List<Map<String, dynamic>>> streamAllCallLogs() {
    return _callService.getAllCallLogsStream();
  }

  /// Add a call log entry
  Future<void> addCallLog({
    required String chatId,
    required String userId,
    required int duration,
    required String callType,
    required bool missed,
  }) async {
    final errorHandler = ErrorHandler();

    try {
      await _callService.addCallLog(
        chatId: chatId,
        userId: userId,
        duration: duration,
        callType: callType,
        missed: missed,
      );

      // Refresh logs (optional — stream already updates UI)
      await loadCallLogs(chatId);
    } catch (e) {
      errorHandler.handleError(e, customMessage: 'Failed to add call log');
    }
  }

  /// Format call duration
  String formatDuration(int seconds) {
    return _callService.getFormattedDuration(seconds);
  }

  /// When call starts
  void startCall(String chatId) {
    isCallActive.value = true;
  }

  /// When call ends
  void endCall() {
    isCallActive.value = false;
    callDuration.value = '0:00';
  }

  /// Update on-screen timer
  void updateCallDuration(int seconds) {
    callDuration.value = formatDuration(seconds);
  }
}
