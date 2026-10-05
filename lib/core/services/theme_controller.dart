import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

/// يتحكم بحالة المود (فاتح/داكن) على مستوى التطبيق ويحفظ التفضيل محليًا.
class ThemeController extends GetxController {
  final CacheService _cacheService = Get.find<CacheService>();

  late final RxBool isDarkMode;

  @override
  void onInit() {
    super.onInit();
    final saved = _cacheService.getIsDarkMode();
    ColorManager.isDark = saved;
    isDarkMode = saved.obs;
  }

  void toggleTheme() => setDarkMode(!isDarkMode.value);

  void setDarkMode(bool value) {
    ColorManager.isDark = value;
    isDarkMode.value = value;
    _cacheService.saveIsDarkMode(value);
    // معظم الودجت في التطبيق تقرأ ألوان ColorManager مباشرة وليس عبر
    // Theme.of(context)، لذا لا تُعاد بناؤها تلقائيًا عند تغيّر الثيم.
    // forceAppUpdate يعيد بناء كامل الشجرة (كما في hot reload) لضمان
    // تحديث كل الصفحات المفتوحة فورًا.
    Get.forceAppUpdate();
  }
}
