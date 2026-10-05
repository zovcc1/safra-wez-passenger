import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/app_config/app_translation.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/complaint_model.dart';
import 'package:safraa_passenger_app/data/repos/complaints_repo.dart';
import 'package:safraa_passenger_app/data/repos/reference_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';

class ComplaintDetailsPageController extends GetxController {
  static const int replyMaxLength = 2000;

  final ComplaintsRepo complaintsRepo = Get.find<ComplaintsRepo>();
  final ReferenceRepo referenceRepo = Get.find<ReferenceRepo>();

  late final int complaintId;

  final replyController = TextEditingController();

  final loadingState = LoadingState.idle.obs;
  final Rxn<ComplaintModel> complaint = Rxn<ComplaintModel>();
  final replies = <ComplaintReplyModel>[].obs;
  final categoryLabel = RxnString();

  final loadingMoreReplies = false.obs;
  final sending = false.obs;
  final hasMoreReplies = false.obs;
  String? _repliesCursor;

  final replyFocusNode = FocusNode();

  /// الرد مسموح بكل الحالات، بما فيها resolved و rejected (الرد لا يعيد فتح
  /// الشكوى؛ الأدمن فقط يقرر).
  bool get complaintClosed => complaint.value?.isClosed ?? false;

  /// السؤال الذي ينتظر المسافر ردّه: آخر رد بجانب الأدمن. يُميَّز فقط بحالة
  /// awaiting_passenger.
  int? get pendingQuestionId {
    if (complaint.value?.isAwaitingPassenger != true) return null;
    for (final reply in replies.reversed) {
      if (!reply.isFromPassenger) return reply.replyId;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    complaintId = args is Map ? (args["complaintId"] as int) : 0;
    load();
  }

  Future<void> load() async {
    loadingState.value = LoadingState.loading;
    _repliesCursor = null;
    hasMoreReplies.value = false;

    final detailsFuture = complaintsRepo.details(complaintId);
    final repliesFuture = complaintsRepo.replies(complaintId);
    final detailsResponse = await detailsFuture;
    final repliesResponse = await repliesFuture;

    if (!detailsResponse.success || !repliesResponse.success) {
      loadingState.value = LoadingState.hasError;
      return;
    }

    complaint.value = detailsResponse.data;
    final page = repliesResponse.data!;
    replies.value = List<ComplaintReplyModel>.from(page.items);
    _applyRepliesPage(page.hasMore, page.nextCursor);
    loadingState.value = LoadingState.doneWithData;
    _loadCategoryLabel();
    if (complaint.value!.isAwaitingPassenger) {
      // نركّز على خانة الرد بعد أن تُبنى الشاشة.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!complaintClosed) replyFocusNode.requestFocus();
      });
    }
  }

  /// يحدّث الشكوى فقط (دون شاشة تحميل): الحالة قد تتغيّر بعد الرد
  /// (awaiting_passenger → in_progress)، وresponse الرد لا يحمل الحالة.
  /// نستبدل الكائن كاملًا فلا يبقى resolution/rejection_reason قديمان.
  Future<void> _refreshComplaint() async {
    final response = await complaintsRepo.details(complaintId);
    if (response.success) complaint.value = response.data;
  }

  void _applyRepliesPage(bool hasMore, String? nextCursor) {
    hasMoreReplies.value = hasMore;
    _repliesCursor = hasMore ? nextCursor : null;
  }

  Future<void> _loadCategoryLabel() async {
    final response = await referenceRepo.complaintCategories();
    if (!response.success) return;
    final key = complaint.value?.category;
    for (final c in response.data!) {
      if (c.key == key) {
        categoryLabel.value = c.labelFor(AppTranslations.currentLang);
        return;
      }
    }
  }

  Future<void> loadMoreReplies() async {
    if (!hasMoreReplies.value || loadingMoreReplies.value) return;
    loadingMoreReplies.value = true;
    final response = await complaintsRepo.replies(
      complaintId,
      cursor: _repliesCursor,
    );
    loadingMoreReplies.value = false;

    if (!response.success) {
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }
    replies.addAll(response.data!.items);
    _applyRepliesPage(response.data!.hasMore, response.data!.nextCursor);
  }

  Future<void> sendReply() async {
    final text = replyController.text.trim();
    if (text.isEmpty || sending.value) return;
    if (text.length > replyMaxLength) {
      CustomToasts(
        message: "complaint_reply_too_long".tr,
        type: CustomToastType.error,
      ).show();
      return;
    }

    sending.value = true;
    final response = await complaintsRepo.addReply(complaintId, text);
    sending.value = false;

    if (!response.success) {
      // 422 هنا فقط لـ body فارغ/طويل (الرد على شكوى مغلقة صار 201).
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }

    final wasClosed = complaintClosed;
    replyController.clear();
    replies.add(response.data!);
    if (wasClosed) {
      // الرد لا يعيد فتح الشكوى: نخبر المسافر أن مسؤولًا سيراجعه ولا نغيّر الحالة.
      CustomToasts(
        message: "complaint_reply_sent_closed".tr,
        type: CustomToastType.success,
      ).show();
    }
    await _refreshComplaint();
  }

  @override
  void onClose() {
    replyController.dispose();
    replyFocusNode.dispose();
    super.onClose();
  }
}
