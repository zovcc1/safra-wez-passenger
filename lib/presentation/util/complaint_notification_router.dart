import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

/// توجيه إشعارات الشكاوى لشاشة التفاصيل عبر data.complaint_id. شاشة التفاصيل
/// تعمل refetch للشكوى والردود عند فتحها، فالحالة (awaiting_passenger،
/// rejected، إعادة الفتح → in_progress) تظهر صحيحة دون معالجة خاصة لكل نوع.
abstract class ComplaintNotificationRouter {
  static const Set<String> types = {
    "complaint_in_progress",
    "complaint_reply",
    "complaint_resolved",
    "complaint_awaiting_info",
    "complaint_rejected",
    "complaint_reopened",
  };

  static bool handles(String type) => types.contains(type);

  /// يرجّع true إذا وُجّه الإشعار. نص الإشعار نفسه يُقرأ من `message` بالسيرفر
  /// (لا ترجمة محلية)، والـ type للأيقونة والتوجيه فقط.
  static bool open(String type, Map<String, dynamic>? data) {
    if (!handles(type)) return false;
    final raw = data?["complaint_id"];
    // FCM data قيمها نصوص دائمًا، فنقبل "7" كما نقبل 7.
    final id = raw is int ? raw : int.tryParse("$raw");
    if (id == null) return false;
    Get.toNamed(
      AppRoutes.complaintDetailsRoute,
      arguments: {"complaintId": id},
    );
    return true;
  }
}
