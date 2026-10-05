import 'dart:async';

import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/app_response.dart';
import 'package:safraa_passenger_app/data/models/payment_request_model.dart';
import 'package:safraa_passenger_app/data/repos/payment_requests_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/util/idempotency_key.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class PaymentRequestDetailsPageController extends GetxController {
  final PaymentRequestsRepo repo = Get.find<PaymentRequestsRepo>();

  late final int paymentRequestId;

  final loadingState = LoadingState.idle.obs;
  final request = Rxn<PaymentRequestModel>();
  final acting = false.obs;

  /// يظهر زر "شحن المحفظة" بعد فشل الموافقة برصيد غير كافٍ (422).
  final insufficientBalance = false.obs;

  /// الثواني المتبقية حتى expires_at (مؤقّت العدّ التنازلي).
  final secondsLeft = 0.obs;
  Timer? _timer;

  // مفتاح واحد لكل نيّة: يُولَّد عند فتح الشاشة ويُعاد استخدامه عند المحاولة
  // بعد شحن الرصيد.
  final String _approveKey = generateIdempotencyKey();
  final String _rejectKey = generateIdempotencyKey();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    paymentRequestId = args is Map ? (args["paymentRequestId"] as int) : 0;
    _load();
  }

  Future<void> _load() async {
    if (request.value == null) loadingState.value = LoadingState.loading;
    final response = await repo.details(paymentRequestId);
    if (!response.success) {
      if (request.value == null) loadingState.value = LoadingState.hasError;
      return;
    }
    _apply(response.data!);
  }

  Future<void> retry() => _load();

  void _apply(PaymentRequestModel model) {
    request.value = model;
    loadingState.value = LoadingState.doneWithData;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final r = request.value;
    if (r == null || !r.isPending || r.expiresAt == null) {
      secondsLeft.value = 0;
      return;
    }
    void tick() {
      final left = r.expiresAt!.difference(DateTime.now()).inSeconds;
      secondsLeft.value = left < 0 ? 0 : left;
      if (left <= 0) {
        _timer?.cancel();
        // المهلة انتهت: الخادم ينهي الطلب (job كل دقيقة) فنعيد الجلب بعد لحظة.
        Future.delayed(const Duration(seconds: 3), _load);
      }
    }

    tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  Future<void> approve() =>
      _act(() => repo.approve(paymentRequestId, _approveKey), isApprove: true);

  Future<void> reject() =>
      _act(() => repo.reject(paymentRequestId, _rejectKey), isApprove: false);

  Future<void> _act(
    Future<AppResponse<PaymentRequestModel>> Function() call, {
    required bool isApprove,
  }) async {
    if (acting.value) return;
    acting.value = true;
    insufficientBalance.value = false;
    final response = await call();
    acting.value = false;

    if (response.success) {
      _apply(response.data!);
      CustomToasts(
        message: isApprove
            ? "payment_request_approved_toast".tr
            : "payment_request_rejected_toast".tr,
        type: CustomToastType.success,
      ).show();
      return;
    }

    final code = response.networkFailure?.code;
    CustomToasts(
      message: response.getErrorMessage(),
      type: CustomToastType.error,
    ).show();
    if (code == 422 && isApprove) {
      // الطلب يبقى pending والمهلة لا تتمدد؛ نوجّه لشحن المحفظة ثم إعادة
      // المحاولة بنفس المفتاح.
      insufficientBalance.value = true;
    } else if (code == 409) {
      // منتهٍ / حالة نهائية / الرحلة تغيّرت: أعد الجلب لنعرض الحالة الفعلية.
      await _load();
    }
  }

  void openWallet() => Get.toNamed(AppRoutes.walletRoute);

  void openBooking() {
    final r = request.value;
    if (r == null) return;
    Get.toNamed(
      AppRoutes.bookingDetailsRoute,
      arguments: {"bookingId": r.bookingId},
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
