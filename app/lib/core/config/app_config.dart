import 'dart:io';
import 'env.dart' as env;

abstract class AppConfig {
  static const supabaseUrl = env.supabaseUrl;
  static const supabaseAnonKey = env.supabaseAnonKey;
  static const googleClientIdIos = env.googleClientIdIos;
  static const googleClientIdWeb = env.googleClientIdWeb;

  static String get revenuecatApiKey {
    if (Platform.isIOS || Platform.isMacOS) {
      return env.revenuecatApiKeyIos;
    } else if (Platform.isAndroid) {
      return env.revenuecatApiKeyAndroid;
    }
    return '';
  }

  static const privacyPolicyUrl = 'https://mydayfocus.com/privacy';
  static const termsOfUseUrl = 'https://mydayfocus.com/terms';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
