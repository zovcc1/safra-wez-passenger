import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:safraa_passenger_app/data/models/passenger_user_model.dart';

const kUserTokenKey = "kUserTokenKey";
const kRefreshTokenKey = "kRefreshTokenKey";
const kTokenExpiresAtKey = "kTokenExpiresAtKey";
const kUserDataKey = "kUserDataKey";
const kLanguageCode = "kLanguageCode";
const kDarkModeKey = "kDarkModeKey";
const kOnboardingSeenKey = "kOnboardingSeenKey";
const kPendingOtpPhoneKey = "kPendingOtpPhoneKey";
const kLastPushTokenKey = "kLastPushTokenKey";
const kGuestModeKey = "kGuestModeKey";

/// طبقة تخزين محلي موحّدة (GetStorage) — لا يوجد أي منطق أدوار/صلاحيات هنا
/// لأن توكن الراكب يحمل abilities=['passenger'] فقط (لا RBAC إطلاقًا).
class CacheService extends GetxService {
  late GetStorage _getStorage;

  CacheService() {
    _getStorage = GetStorage();
  }

  /// اللغة
  Future<void> saveLanguage(String languageCode) async {
    await _getStorage.write(kLanguageCode, languageCode);
  }

  String getLanguage() => _getStorage.read(kLanguageCode) ?? 'ar';

  /// المود (فاتح/داكن)
  Future<void> saveIsDarkMode(bool isDark) async {
    await _getStorage.write(kDarkModeKey, isDark);
  }

  bool getIsDarkMode() => _getStorage.read(kDarkModeKey) ?? false;

  /// Onboarding — يُعرض مرة واحدة فقط
  Future<void> setOnboardingSeen() async {
    await _getStorage.write(kOnboardingSeenKey, true);
  }

  bool hasSeenOnboarding() => _getStorage.read(kOnboardingSeenKey) ?? false;

  /// وضع الضيف — تصفّح بدون توكن (البحث عن الرحلات فقط). يُحفظ ليعود
  /// التطبيق مباشرة للرئيسية، ويُمسح عند أي تسجيل دخول ناجح.
  Future<void> setGuestMode(bool value) async {
    if (value) {
      await _getStorage.write(kGuestModeKey, true);
    } else {
      await _getStorage.remove(kGuestModeKey);
    }
  }

  bool isGuestMode() =>
      !isLoggedIn() && (_getStorage.read(kGuestModeKey) ?? false);

  /// حالة تسجيل الدخول
  bool isLoggedIn() => _getStorage.hasData(kUserTokenKey);

  Future<String> getUserToken() async {
    String? token = _getStorage.read(kUserTokenKey);
    return token ?? "";
  }

  Future<String> getUserRefreshToken() async {
    String? refreshToken = _getStorage.read(kRefreshTokenKey);
    return refreshToken ?? "";
  }

  Future<void> storeUserToken(String token) async {
    await _getStorage.write(kUserTokenKey, token);
  }

  Future<void> storeUserRefreshToken(String refreshToken) async {
    await _getStorage.write(kRefreshTokenKey, refreshToken);
  }

  /// يحفظ التوكنين معًا ويحسب وقت انتهاء الصلاحية (expires_in بالثواني).
  Future<void> storeSession({
    required String token,
    required String refreshToken,
    int? expiresIn,
  }) async {
    await setGuestMode(false);
    await storeUserToken(token);
    await storeUserRefreshToken(refreshToken);
    if (expiresIn != null) {
      final expiresAt =
          DateTime.now().millisecondsSinceEpoch + expiresIn * 1000;
      await _getStorage.write(kTokenExpiresAtKey, expiresAt);
    } else {
      await _getStorage.remove(kTokenExpiresAtKey);
    }
  }

  /// هل التوكن الحالي منتهٍ أو قريب من الانتهاء (هامش أمان 60 ثانية)؟
  /// لا يوجد expiresAt مخزّن (expires_in لم يُرسل) => يُعتبر غير قريب الانتهاء.
  bool isTokenNearExpiry({int thresholdSeconds = 60}) {
    final int? expiresAt = _getStorage.read(kTokenExpiresAtKey);
    if (expiresAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= (expiresAt - thresholdSeconds * 1000);
  }

  Future<void> storeUser(PassengerUserModel user) async {
    await _getStorage.write(kUserDataKey, jsonEncode(user.toJson()));
  }

  PassengerUserModel? getUser() {
    final String? raw = _getStorage.read(kUserDataKey);
    if (raw == null) return null;
    try {
      return PassengerUserModel.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  /// رقم الهاتف بانتظار تفعيل OTP — يُخزَّن عند دخول صفحة التحقق حتى لو
  /// أغلق المستخدم التطبيق قبل إدخال الكود، ويُمسح فور نجاح التحقق.
  Future<void> storePendingOtpPhone(String phoneNumber) async {
    await _getStorage.write(kPendingOtpPhoneKey, phoneNumber);
  }

  String? getPendingOtpPhone() => _getStorage.read(kPendingOtpPhoneKey);

  Future<void> clearPendingOtpPhone() async {
    await _getStorage.remove(kPendingOtpPhoneKey);
  }

  /// آخر Push Token تم تسجيله فعليًا على الخادم — يُستخدم لإرساله ضمن
  /// DELETE عند تسجيل الخروج.
  Future<void> storeLastPushToken(String? token) async {
    if (token == null) {
      await _getStorage.remove(kLastPushTokenKey);
    } else {
      await _getStorage.write(kLastPushTokenKey, token);
    }
  }

  String? getLastPushToken() => _getStorage.read(kLastPushTokenKey);

  /// تسجيل الخروج: مسح بيانات الجلسة فقط دون مسح تفضيلات الجهاز
  /// (اللغة/المود/onboarding_seen).
  Future<void> clearSession() async {
    await _getStorage.remove(kUserTokenKey);
    await _getStorage.remove(kRefreshTokenKey);
    await _getStorage.remove(kTokenExpiresAtKey);
    await _getStorage.remove(kUserDataKey);
    await _getStorage.remove(kLastPushTokenKey);
  }

  /// مسح كامل للتخزين المحلي (يُستخدم فقط عند سرقة/إعادة استخدام refresh token)
  Future<void> clearAll() async {
    await _getStorage.erase();
  }
}
