import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoCloudService {
  static final ZegoCloudService _instance = ZegoCloudService._internal();
  factory ZegoCloudService() => _instance;
  ZegoCloudService._internal();

  // Zego Cloud Credentials
  static const int appId = 880377377;
  static const String appSign =
      'e63bb89680d72cc6bf929988023b2470485c33729eeae8b94e23aa29d410ed08';

  /// ===========================
  /// MARK: - Initialize Zego
  /// ===========================
  Future<void> initZegoCloud({
    required String userId,
    required String userName,
  }) async {
    try {
      // Initialize ZegoUIKit with user info
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: appId,
        appSign: appSign,
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
      );

      print('✅ Zego Cloud initialized for user: $userId');
    } catch (e) {
      print('❌ Zego Init Error: $e');
      // Fallback: try initializing without user info
      try {
        await ZegoUIKit().init(appID: appId, appSign: appSign);
        print('✅ Fallback Zego init without user info succeeded');
      } catch (e2) {
        print('❌ Fallback Zego Init Failed: $e2');
        rethrow;
      }
    }
  }

  /// ===========================
  /// MARK: - Get Call Widget
  /// ===========================
  Widget getCallWidget({
    required String chatId,
    required String userId,
    required String userName,
    required bool isVideoCall,
  }) {
    return ZegoUIKitPrebuiltCall(
      appID: appId,
      appSign: appSign,
      userID: userId, // ⚡ Must provide userID
      userName: userName, // ⚡ Must provide userName
      callID: chatId,
      config: isVideoCall
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
    );
  }

  /// ===========================
  /// MARK: - Avatar Widgets
  /// ===========================
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

  Color _getColorFromUserId(String userId) {
    final colors = [
      Colors.red.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.pink.shade400,
    ];
    return colors[userId.hashCode % colors.length];
  }

  /// ===========================
  /// MARK: - Utilities
  /// ===========================
  bool isInitialized() => appId != 0 && appSign.isNotEmpty;

  /// ===========================
  /// MARK: - Invitation Service
  /// ===========================
  ZegoUIKitPrebuiltCallInvitationService getCallInvitationService() {
    return ZegoUIKitPrebuiltCallInvitationService();
  }
}
