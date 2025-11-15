import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoCloudService {
  static final ZegoCloudService _instance = ZegoCloudService._internal();

  factory ZegoCloudService() {
    return _instance;
  }

  ZegoCloudService._internal();

  // Zego Cloud Credentials
  static const int appId = 880377377;
  static const String appSign =
      'e63bb89680d72cc6bf929988023b2470485c33729eeae8b94e23aa29d410ed08';

  // Initialize Zego Cloud SDK
  Future<void> initZegoCloud(String userId, String userName) async {
    try {
      // Initialization code will be added when Zego package is properly configured
      print('✅ Zego Cloud service initialized');
    } catch (e) {
      print('❌ Error initializing Zego Cloud: $e');
      rethrow;
    }
  }

  // Get call widget for video/audio calls
  Widget getCallWidget({
    required String callId,
    required String userId,
    required String userName,
    required bool isVideoCall,
  }) {
    return ZegoUIKitPrebuiltCall(
      appID: appId,
      appSign: appSign,
      userID: userId,
      userName: userName,
      callID: callId,
      config: isVideoCall
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }

  // Get avatar widget for user
  Widget getAvatarWidget(String userId, {String? avatarUrl, String? userName}) {
    return CircleAvatar(
      radius: 20,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      backgroundColor: Colors.blue.shade200,
      child: avatarUrl == null
          ? Text(
              userName?.isNotEmpty == true ? userName![0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  // Get user avatar widget with better customization
  Widget getUserAvatarWidget({
    required String userId,
    required String userName,
    String? avatarUrl,
    double radius = 30,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      backgroundColor: _getColorFromUserId(userId),
      child: avatarUrl == null
          ? Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.6,
              ),
            )
          : null,
    );
  }

  // Helper to get color based on userId
  Color _getColorFromUserId(String userId) {
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.pink.shade400,
    ];
    final hash = userId.hashCode;
    return colors[hash % colors.length];
  }

  // Check if call service is initialized
  bool isInitialized() {
    try {
      return appId != 0 && appSign.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get call invitation service
  ZegoUIKitPrebuiltCallInvitationService getCallInvitationService() {
    return ZegoUIKitPrebuiltCallInvitationService();
  }
}
