/// App environment, resolved at compile time via `--dart-define=APP_ENV=prod`.
/// Defaults to staging so a plain `flutter run`/`flutter build` never
/// accidentally targets production.
class Env {
  static const String name = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'staging',
    // defaultValue: 'staging',
  );

  static const bool isProd = name == 'prod';

  static const String apiBaseUrl = isProd
      ? 'https://api.187-127-94-104.sslip.io/api/v1/'
      : 'https://api-staging.187-127-94-104.sslip.io/api/v1/';

  /// Reverb (Pusher protocol). المفتاح يُمرَّر وقت البناء عبر
  /// --dart-define=REVERB_APP_KEY=xxx (مفتاح مختلف لكل بيئة؛ المفتاح علني بطبيعته فالقيم الافتراضية هنا).
  static const String reverbAppKey = String.fromEnvironment(
    'REVERB_APP_KEY',
    defaultValue: isProd
        ? 'b19db2feed6bfe4eb7167e29b3137f15'
        : '83ee667f83078d1f468e7ec4e09580eb',
  );

  /// مفتاح Directions API (مسارات الطرق بين نقطتين). يُمرَّر وقت البناء
  /// --dart-define=GOOGLE_DIRECTIONS_KEY=... ولا يُكتب بالكود؛ بدونه يُرسم خط
  /// مستقيم. استخدم مفتاحًا منفصلًا مقيَّدًا بـ Directions API فقط.
  static const String googleDirectionsKey = String.fromEnvironment(
    'GOOGLE_DIRECTIONS_KEY',
  );

  static const String reverbHost = isProd
      ? 'api.187-127-94-104.sslip.io'
      : 'api-staging.187-127-94-104.sslip.io';

  static const String broadcastingAuthUrl = '${apiBaseUrl}broadcasting/auth';
}
