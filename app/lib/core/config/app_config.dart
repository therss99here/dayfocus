import 'env.dart' as env;

abstract class AppConfig {
  static const supabaseUrl = env.supabaseUrl;
  static const supabaseAnonKey = env.supabaseAnonKey;
  static const googleClientIdIos = env.googleClientIdIos;
  static const googleClientIdWeb = env.googleClientIdWeb;
  static const revenuecatApiKey = env.revenuecatApiKey;

  static const privacyPolicyUrl = 'https://mydayfocus.com/privacy';
  static const termsOfUseUrl = 'https://mydayfocus.com/terms';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
