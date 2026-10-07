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

  /// مفتاح Directions API (مسارات الطرق بين نقطتين). الافتراضي هو مفتاح خرائط
  /// جوجل نفسه (AndroidManifest)، ويمكن تجاوزه وقت البناء بـ
  /// --dart-define=GOOGLE_DIRECTIONS_KEY=... ؛ بدونه يُرسم خط مستقيم.
  static const String googleDirectionsKey = String.fromEnvironment(
    'GOOGLE_DIRECTIONS_KEY',
    defaultValue: 'AIzaSyDe6-XzW5kxJLzaTSoVjm_8PLTEucoMKvk',
  );

  /// هوية التطبيق التي يتحقق منها مفتاح جوجل المقيَّد (ترويسات Routes API).
  /// الشهادة = SHA-1 لـ debug.keystore (يوقّع به build.gradle حاليًا)؛ غيّرها
  /// عند التوقيع بمفتاح release/Play.
  static const String androidPackage = 'com.safraa.passenger_app';
  static const String androidCertSha1 = String.fromEnvironment(
    'ANDROID_CERT_SHA1',
    defaultValue: '157748134AF612A1EC6E11CF45366DA883D059F0',
  );
  static const String iosBundleId = 'com.safraa.passengerApp';

  static const String reverbHost = isProd
      ? 'api.187-127-94-104.sslip.io'
      : 'api-staging.187-127-94-104.sslip.io';

  static const String broadcastingAuthUrl = '${apiBaseUrl}broadcasting/auth';
}
