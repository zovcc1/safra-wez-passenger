import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/presentation/pages/bookings_page/bookings_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/main_page/main_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/payment_requests_page/payment_requests_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/profile_page/profile_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/trips_page/trips_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/visas_page/visas_page_controller.dart';

/// PageView بـ MainPage يبقي كل التبويبات موجودة معًا (لا Lazy loading بين
/// التبويبات)، لذا كونترولرات التبويبات تُسجَّل هنا دفعة واحدة عند دخول
/// mainRoute بدل تسجيل كل تبويب بمسار GetPage منفصل.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainPageController());
    Get.put(TripsPageController());
    // الضيف لا يملك توكن: هذه الكونترولرات تستدعي endpoints محمية في onInit،
    // فلا نسجّلها له (تُستبدل صفحاتها بـ GuestGateWidget).
    if (Get.find<CacheService>().isLoggedIn()) {
      Get.put(BookingsPageController());
      Get.put(PaymentRequestsPageController());
      Get.put(VisasPageController());
      Get.put(ProfilePageController());
    }
  }
}
