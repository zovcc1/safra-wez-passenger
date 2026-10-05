import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/core/services/deep_link_service.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:safraa_passenger_app/core/services/permission_service.dart';
import 'package:safraa_passenger_app/core/services/push_notification_service.dart';
import 'package:safraa_passenger_app/core/services/realtime_service.dart';
import 'package:safraa_passenger_app/core/services/theme_controller.dart';
import 'package:safraa_passenger_app/data/repos/auth_repo.dart';
import 'package:safraa_passenger_app/data/repos/bookings_repo.dart';
import 'package:safraa_passenger_app/data/repos/complaints_repo.dart';
import 'package:safraa_passenger_app/data/repos/notifications_repo.dart';
import 'package:safraa_passenger_app/data/repos/payment_requests_repo.dart';
import 'package:safraa_passenger_app/data/repos/reference_repo.dart';
import 'package:safraa_passenger_app/data/repos/trips_repo.dart';
import 'package:safraa_passenger_app/data/repos/visa_repo.dart';
import 'package:safraa_passenger_app/data/repos/wallet_repo.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CacheService());
    Get.put(ThemeController());
    Get.put(ApiService());
    Get.put(DeepLinkService());
    Get.put(PermissionService());
    Get.put(PushNotificationService());
    Get.put(RealtimeService());
    Get.put(AuthRepo());
    Get.put(ReferenceRepo());
    Get.put(TripsRepo());
    Get.put(BookingsRepo());
    Get.put(ComplaintsRepo());
    Get.put(VisaRepo());
    Get.put(WalletRepo());
    Get.put(PaymentRequestsRepo());
    Get.put(NotificationsRepo());
  }
}
