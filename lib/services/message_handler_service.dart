import 'dart:io';
import 'package:chat_app/services/supabase_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Complete Message Service for handling all message types
class MessageHandlerService {
  static final MessageHandlerService _instance =
      MessageHandlerService._internal();

  factory MessageHandlerService() => _instance;

  MessageHandlerService._internal();

  final _supabaseService = SupabaseService();
  final _supabase = Supabase.instance.client;

  // ===========================
  // MARK: - Message Sending
  // ===========================

  /// Send text message
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      await _supabaseService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        content: text,
        messageType: 'text',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
      rethrow;
    }
  }

  /// Send voice message
  Future<void> sendVoiceMessage({
    required String chatId,
    required String senderId,
    required String audioFilePath,
  }) async {
    try {
      final voiceUrl = await uploadFile(audioFilePath, 'voices');
      if (voiceUrl != null) {
        await _supabaseService.sendMessage(
          chatId: chatId,
          senderId: senderId,
          content: '🎙️ Voice message',
          messageType: 'audio',
          mediaUrl: voiceUrl,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send voice message: $e');
      rethrow;
    }
  }

  /// Send image message
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String imagePath,
    String caption = '🖼️ Image',
  }) async {
    try {
      final imageUrl = await uploadFile(imagePath, 'images');
      if (imageUrl != null) {
        await _supabaseService.sendMessage(
          chatId: chatId,
          senderId: senderId,
          content: caption,
          messageType: 'image',
          mediaUrl: imageUrl,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send image: $e');
      rethrow;
    }
  }

  /// Send video message
  Future<void> sendVideoMessage({
    required String chatId,
    required String senderId,
    required String videoPath,
    String caption = '🎬 Video',
  }) async {
    try {
      final videoUrl = await uploadFile(videoPath, 'videos');
      if (videoUrl != null) {
        await _supabaseService.sendMessage(
          chatId: chatId,
          senderId: senderId,
          content: caption,
          messageType: 'video',
          mediaUrl: videoUrl,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send video: $e');
      rethrow;
    }
  }

  // ===========================
  // MARK: - File Upload
  // ===========================

  Future<String?> uploadFile(String filePath, String folder) async {
    try {
      final file = File(filePath);
      final fileName =
          '$folder/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      await _supabase.storage.from('messages').upload(fileName, file);
      return _supabase.storage.from('messages').getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // ===========================
  // MARK: - Message Retrieval
  // ===========================

  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    try {
      return await _supabaseService.getChatMessages(chatId);
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamChatMessages(String chatId) {
    return _supabaseService.getChatMessagesStream(chatId);
  }

  // ===========================
  // MARK: - Message Updates
  // ===========================

  Future<void> markAsRead(String messageId) async {
    try {
      await _supabaseService.markMessageAsRead(messageId);
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  Future<int> getUnreadCount(String chatId, String userId) async {
    try {
      return await _supabaseService.getUnreadMessageCount(chatId, userId);
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // ===========================
  // MARK: - Message Display Logic
  // ===========================

  String getMessageDisplayText(Map<String, dynamic> message) {
    final messageType = message['message_type'] ?? 'text';
    final text = message['content'] ?? '';

    switch (messageType) {
      case 'text':
        return text;
      case 'audio':
        return '🎙️ Voice message';
      case 'image':
        return '🖼️ Image';
      case 'video':
        return '🎬 Video';
      case 'call':
        return '☎️ Call';
      default:
        return text;
    }
  }

  bool hasAttachment(Map<String, dynamic> message) =>
      message['media_url'] != null;

  String? getAttachmentUrl(Map<String, dynamic> message) =>
      message['media_url'];

  // ===========================
  // MARK: - Typing Status
  // ===========================

  Future<void> setTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await _supabaseService.setTypingStatus(chatId, userId, isTyping);
    } catch (e) {
      print('Error setting typing status: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamTypingUsers(String chatId) {
    return _supabaseService.getTypingStatusStream(chatId);
  }

  // ===========================
  // MARK: - Call Logging
  // ===========================

  Future<void> logCall({
    required String initiatorId,
    required String recipientId,
    required int durationInSeconds,
    required String callType, // 'voice' or 'video'
    required bool missed,
  }) async {
    try {
      await _supabaseService.addCallLog(
        initiatorId: initiatorId,
        recipientId: recipientId,
        duration: durationInSeconds,
        callType: callType,
        missed: missed,
      );
    } catch (e) {
      print('Error logging call: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCallLogs(String userId) async {
    try {
      return await _supabaseService.getCallLogs(userId);
    } catch (e) {
      print('Error getting call logs: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamCallLogs(String userId) {
    return _supabaseService.getCallLogsStream(userId);
  }
}
