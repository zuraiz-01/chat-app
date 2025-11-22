/// App-wide constants to replace magic strings
class AppConstants {
  // Storage buckets
  static const String chatMediaBucket = 'chat-media';
  static const String profileImagesBucket = 'profile-images';

  // Message types
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeVideo = 'video';
  static const String messageTypeVoice = 'voice';

  // Call types
  static const String callTypeVoice = 'voice';
  static const String callTypeVideo = 'video';

  // File extensions
  static const String audioExtension = '.aac';
  static const String imageExtension = '.jpg';
  static const String videoExtension = '.mp4';

  // Limits
  static const int maxMessageLength = 1000;
  static const int maxGroupMembers = 50;
  static const int messagesPageSize = 50;
  static const int searchResultsLimit = 20;

  // Timeouts
  static const Duration typingTimeout = Duration(seconds: 3);
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration callReconnectTimeout = Duration(seconds: 30);

  // Cache keys
  static const String messagesCacheKey = 'messages_cache';
  static const String usersCacheKey = 'users_cache';
  static const String chatsCacheKey = 'chats_cache';

  // Notification channels
  static const String callChannelId = 'call_channel';
  static const String messageChannelId = 'message_channel';
  static const String generalChannelId = 'general_channel';

  // Error messages
  static const String networkErrorMessage =
      'Please check your internet connection and try again.';
  static const String authErrorMessage =
      'Authentication failed. Please sign in again.';
  static const String permissionErrorMessage =
      'Permission denied. Please check your app permissions.';
  static const String validationErrorMessage =
      'Please check your input and try again.';

  // UI constants
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double avatarRadius = 20.0;
  static const double messageBubbleRadius = 16.0;
}
