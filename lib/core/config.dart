import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the app
class AppConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get zegoAppId => dotenv.env['ZEGO_APP_ID'] ?? '';
  static String get zegoAppSign => dotenv.env['ZEGO_APP_SIGN'] ?? '';
  static int get zegoAppIdValue => int.tryParse(zegoAppId) ?? 0;

  /// Validate only required environment variables
  static bool validate() {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }
}
