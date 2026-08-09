import 'env.dart' as env;

abstract class AppConfig {
  static const supabaseUrl = env.supabaseUrl;
  static const supabaseAnonKey = env.supabaseAnonKey;
  static const googleClientIdIos = env.googleClientIdIos;
  static const googleClientIdWeb = env.googleClientIdWeb;

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
