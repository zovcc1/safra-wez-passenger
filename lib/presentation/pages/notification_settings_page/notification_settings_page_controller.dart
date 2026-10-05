import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/notification_models.dart';
import 'package:safraa_passenger_app/data/repos/notifications_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';

class NotificationSettingsPageController extends GetxController {
  final NotificationsRepo repo = Get.find<NotificationsRepo>();

  final loadingState = LoadingState.idle.obs;
  final preferences = <NotificationPreferenceModel>[].obs;
  final saving = <String>{}.obs;

  /// الفئات بترتيب العرض. فئة لم تُحفظ = enabled:true، فنكمّل ما ينقص من الرد.
  static const _order = ["transactional", "reminder", "promotional", "service"];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loadingState.value = LoadingState.loading;
    final response = await repo.preferences();
    if (!response.success) {
      loadingState.value = LoadingState.hasError;
      return;
    }
    _apply(response.data!);
    loadingState.value = LoadingState.doneWithData;
  }

  void _apply(List<NotificationPreferenceModel> list) {
    final byCategory = {for (final p in list) p.category: p};
    preferences.assignAll([
      for (final c in _order)
        if (byCategory[c] != null) byCategory[c]!,
      ...list.where((p) => !_order.contains(p.category)),
    ]);
  }

  /// PUT جزئي: نرسل الفئة المتغيّرة فقط، ونتراجع عن التبديل إن فشل الطلب.
  Future<void> toggle(NotificationPreferenceModel pref, bool value) async {
    if (!pref.isOptional || saving.contains(pref.category)) return;
    final index = preferences.indexOf(pref);
    saving.add(pref.category);
    pref.enabled = value;
    preferences.refresh();

    final response = await repo.updatePreference(pref.category, value);
    saving.remove(pref.category);

    if (response.success) {
      _apply(response.data!);
    } else {
      if (index != -1) preferences[index].enabled = !value;
      preferences.refresh();
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
    }
  }
}
