import 'package:chat_app/services/call_service.dart';
// ignore: unused_import
import 'package:chat_app/service/auth_service.dart';
import 'package:get/get.dart';
import '../core/error_handler.dart';

class CallProvider extends GetxController {
  final _callService = CallService();

  final RxList<Map<String, dynamic>> callLogs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCallActive = false.obs;
  final RxString callDuration = '0:00'.obs;

  // Load call logs by chatId
  Future<void> loadCallLogs(String chatId) async {
    final errorHandler = ErrorHandler();

    try {
      isLoading.value = true;
      final logs = await _callService.getCallLogs(chatId);
      callLogs.value = logs;
    } catch (e) {
      errorHandler.handleError(e, customMessage: 'Failed to load call logs');
    } finally {
      isLoading.value = false;
    }
  }

  // Stream logs by chatId
  Stream<List<Map<String, dynamic>>> streamCallLogs(String chatId) {
    return _callService.getCallLogsStream(chatId);
  }

  // Stream all call logs for the user
  Stream<List<Map<String, dynamic>>> streamAllCallLogs() {
    return _callService.getAllCallLogsStream();
  }

  // Add call log
  Future<void> addCallLog({
    required String chatId,
    required String userId, // caller id
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

      await loadCallLogs(chatId);
    } catch (e) {
      errorHandler.handleError(e, customMessage: 'Failed to add call log');
    }
  }

  String formatDuration(int seconds) {
    return _callService.getFormattedDuration(seconds);
  }

  // Start call (chatId now required)
  void startCall(String chatId) {
    isCallActive.value = true;
  }

  void endCall() {
    isCallActive.value = false;
    callDuration.value = '0:00';
  }

  void updateCallDuration(int seconds) {
    callDuration.value = formatDuration(seconds);
  }
}
