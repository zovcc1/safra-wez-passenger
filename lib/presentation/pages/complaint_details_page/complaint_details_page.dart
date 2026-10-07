import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/complaint_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/complaint_details_page/complaint_details_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/complaint_display.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class ComplaintDetailsPage extends GetView<ComplaintDetailsPageController> {
  const ComplaintDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: NormalAppBar(
          title: "complaint_details_title".tr,
          backIcon: true,
        ),
        body: AppBackground(child: SafeArea(child: Obx(() => _body()))),
      ),
    );
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.idle || state == LoadingState.loading) {
      return const AppLoader();
    }

    if (state == LoadingState.hasError) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ErrorPlaceholderWidget(
              title: "complaint_details_error_title".tr,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: AppButton(
              text: "common_retry".tr,
              onPressed: controller.load,
            ),
          ),
        ],
      );
    }

    final complaint = controller.complaint.value!;
    final replies = controller.replies.toList();
    final hasMore = controller.hasMoreReplies.value;
    final loadingMore = controller.loadingMoreReplies.value;
    final categoryLabel = controller.categoryLabel.value ?? complaint.category;
    final showResolution =
        complaint.statusType == ComplaintStatus.resolved &&
        complaint.resolution != null &&
        complaint.resolution!.isNotEmpty;
    final showRejection =
        complaint.statusType == ComplaintStatus.rejected &&
        complaint.rejectionReason != null &&
        complaint.rejectionReason!.isNotEmpty;
    final pendingQuestionId = controller.pendingQuestionId;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppPadding.p16),
              children: [
                FadeSlideIn(
                  child: _HeaderCard(
                    complaint: complaint,
                    categoryLabel: categoryLabel,
                  ),
                ),
                if (complaint.isAwaitingPassenger) ...[
                  const SizedBox(height: AppPadding.p8),
                  const FadeSlideIn(child: _AwaitingBanner()),
                ],
                if (complaint.statusType != ComplaintStatus.unknown) ...[
                  const SizedBox(height: AppPadding.p8),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: _ProgressCard(status: complaint.status),
                  ),
                ],
                const SizedBox(height: AppPadding.p8),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: _DescriptionCard(text: complaint.description),
                ),
                if (showResolution) ...[
                  const SizedBox(height: AppPadding.p8),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: _ResolutionCard(
                      resolution: complaint.resolution!,
                      resolvedAt: complaint.resolvedAt,
                    ),
                  ),
                ],
                if (showRejection) ...[
                  const SizedBox(height: AppPadding.p8),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 180),
                    child: _RejectionCard(reason: complaint.rejectionReason!),
                  ),
                ],
                const SizedBox(height: AppPadding.p16),
                _CardTitle(
                  icon: Icons.forum_outlined,
                  text: "complaint_replies_title".tr,
                ),
                const SizedBox(height: AppPadding.p8),
                if (replies.isEmpty)
                  const _EmptyReplies()
                else
                  for (final reply in replies)
                    _ReplyBubble(
                      reply: reply,
                      highlighted: reply.replyId == pendingQuestionId,
                    ),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: AppPadding.p4),
                    child: AppButton(
                      text: "complaint_replies_load_more".tr,
                      backgroundColor: ColorManager.colorTextFieldFill,
                      fontColor: ColorManager.colorFontPrimary,
                      radius: 12,
                      loadingMode: loadingMore,
                      onPressed: controller.loadMoreReplies,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // الرد متاح بكل الحالات، والمغلقة تعرض تلميحًا بأن مسؤولًا سيراجع الرسالة.
        _ReplyInput(controller: controller, closed: complaint.isClosed),
      ],
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: ColorManager.colorWhite,
  borderRadius: BorderRadius.circular(AppSize.s16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ],
);

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.complaint, required this.categoryLabel});

  final ComplaintModel complaint;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    final status = ComplaintStatusDisplay.of(complaint.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TripCardHeader(
            icon: complaintCategoryIcon(complaint.category),
            title: categoryLabel,
            badge: status.label,
            badgeColor: status.color,
          ),
          const SizedBox(height: 8),
          TripInfoBox(
            start: TripInfoItem(
              icon: Icons.calendar_today_outlined,
              title: DateConverter.dateToStringAR(complaint.createdAt),
              subtitle: DateConverter.timeUTCToString(complaint.createdAt),
            ),
            end: TripInfoItem(
              icon: Icons.tag,
              title: "#${complaint.complaintId}",
              subtitle: complaint.bookingId == null
                  ? null
                  : "file_complaint_linked_booking".trParams({
                      "id": "${complaint.bookingId}",
                    }),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنوان قسم داخل كارد: أيقونة في مربع ملوّن + نص خفيف.
class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? ColorManager.colorPrimary;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: c),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: FontSize.s15,
              fontWeight: FontWeight.w500,
              color: color ?? ColorManager.colorFontPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// مخطط تقدّم الشكوى: مفتوحة ← قيد المعالجة ← تمت المعالجة.
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    // الشكوى قد تعود لوراء (إعادة الفتح)، فالمخطط يعكس الحالة الحالية فقط:
    // awaiting_passenger تُعرض كخطوة المعالجة، وrejected كخطوة النهاية.
    final steps = [
      "open",
      status == "awaiting_passenger" ? "awaiting_passenger" : "in_progress",
      status == "rejected" ? "rejected" : "resolved",
    ];
    final current = switch (status) {
      "open" => 0,
      "in_progress" || "awaiting_passenger" => 1,
      _ => 2,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _StepDot(
              step: steps[i],
              reached: i <= current,
              isCurrent: i == current,
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: i < current
                          ? ColorManager.colorPrimary.withValues(alpha: 0.35)
                          : ColorManager.colorDivider.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.reached,
    required this.isCurrent,
  });

  final String step;
  final bool reached;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final display = ComplaintStatusDisplay.of(step);
    final color = reached ? display.color : ColorManager.colorGrey6;
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: reached
                  ? color.withValues(alpha: isCurrent ? 0.18 : 0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: reached ? 0.6 : 0.35),
                width: 1.2,
              ),
            ),
            child: reached
                ? Icon(
                    step == "rejected"
                        ? Icons.close_rounded
                        : Icons.check_rounded,
                    size: 13,
                    color: color,
                  )
                : null,
          ),
          const SizedBox(height: 5),
          Text(
            display.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: FontSize.s10_5,
              fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
              color: isCurrent ? color : ColorManager.colorGrey6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.notes_rounded,
            text: "file_complaint_description".tr,
          ),
          const SizedBox(height: AppPadding.p8),
          Text(
            text,
            style: TextStyle(
              fontSize: FontSize.s12,
              height: 1.6,
              color: ColorManager.colorDoveGray600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolutionCard extends StatelessWidget {
  const _ResolutionCard({required this.resolution, required this.resolvedAt});

  final String resolution;
  final DateTime? resolvedAt;

  @override
  Widget build(BuildContext context) {
    final green = ColorManager.colorGreen3;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSize.s16),
        border: Border.all(color: green.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _CardTitle(
                  icon: Icons.verified_outlined,
                  text: "complaint_resolution_title".tr,
                  color: green,
                ),
              ),
              if (resolvedAt != null)
                Text(
                  DateConverter.dateToStringAR(resolvedAt),
                  style: TextStyle(
                    fontSize: FontSize.s11,
                    color: ColorManager.colorGrey6,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppPadding.p8),
          Text(
            resolution,
            style: TextStyle(
              fontSize: FontSize.s12,
              height: 1.6,
              color: ColorManager.colorDoveGray600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AwaitingBanner extends StatelessWidget {
  const _AwaitingBanner();

  @override
  Widget build(BuildContext context) {
    final orange = ColorManager.colorOrange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSize.s16),
        border: Border.all(color: orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.mark_chat_unread_outlined, size: 24, color: orange),
          const SizedBox(width: AppPadding.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "complaint_awaiting_title".tr,
                  style: TextStyle(
                    fontSize: FontSize.s14,
                    fontWeight: FontWeight.w500,
                    color: orange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "complaint_awaiting_subtitle".tr,
                  style: TextStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectionCard extends StatelessWidget {
  const _RejectionCard({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final red = ColorManager.colorError300;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSize.s16),
        border: Border.all(color: red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.info_outline_rounded,
            text: "complaint_rejection_title".tr,
            color: red,
          ),
          const SizedBox(height: AppPadding.p8),
          Text(
            reason,
            style: TextStyle(
              fontSize: FontSize.s12,
              height: 1.6,
              color: ColorManager.colorDoveGray600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReplies extends StatelessWidget {
  const _EmptyReplies();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPadding.p24),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 36,
            color: ColorManager.colorGrey6.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppPadding.p8),
          Text(
            "complaint_replies_empty".tr,
            style: TextStyle(
              fontSize: FontSize.s13,
              color: ColorManager.colorGrey6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  const _ReplyBubble({required this.reply, this.highlighted = false});

  final ComplaintReplyModel reply;

  /// السؤال الذي ينتظر ردّ المسافر (awaiting_passenger).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final mine = reply.isFromPassenger;
    const radius = Radius.circular(16);
    const tail = Radius.circular(4);

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: mine
            ? ColorManager.colorPrimary.withValues(alpha: 0.12)
            : ColorManager.colorWhite,
        border: highlighted
            ? Border.all(color: ColorManager.colorOrange, width: 1.5)
            : null,
        borderRadius: BorderRadiusDirectional.only(
          topStart: radius,
          topEnd: radius,
          bottomStart: mine ? radius : tail,
          bottomEnd: mine ? tail : radius,
        ),
        boxShadow: mine
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mine
                ? "complaint_author_you".tr
                : highlighted
                ? "${"complaint_author_support".tr} • ${"complaint_needs_reply".tr}"
                : "complaint_author_support".tr,
            style: TextStyle(
              fontSize: FontSize.s11,
              fontWeight: FontWeight.w500,
              color: mine
                  ? ColorManager.colorPrimary
                  : ColorManager.colorFontPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reply.body,
            style: TextStyle(
              fontSize: FontSize.s13,
              height: 1.4,
              color: ColorManager.colorFontPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${DateConverter.dateToStringAR(reply.createdAt)} "
            "${DateConverter.timeUTCToString(reply.createdAt)}",
            style: TextStyle(
              fontSize: FontSize.s10,
              fontWeight: FontWeight.w400,
              color: ColorManager.colorGrey6,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!mine) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: ColorManager.colorPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                size: 17,
                color: ColorManager.colorPrimary,
              ),
            ),
            const SizedBox(width: AppPadding.p8),
          ],
          bubble,
        ],
      ),
    );
  }
}

class _ReplyInput extends StatelessWidget {
  const _ReplyInput({required this.controller, required this.closed});

  final ComplaintDetailsPageController controller;
  final bool closed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (closed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppPadding.p8),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: ColorManager.colorGrey6,
                  ),
                  const SizedBox(width: AppPadding.p8),
                  Expanded(
                    child: Text(
                      "complaint_closed_reply_hint".tr,
                      style: TextStyle(
                        fontSize: FontSize.s12,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller.replyController,
                  focusNode: controller.replyFocusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: "complaint_reply_hint".tr,
                    filled: true,
                    fillColor: ColorManager.colorWhite,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                      vertical: AppPadding.p12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: ColorManager.colorTextFieldEnabledBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                        color: ColorManager.colorTextFieldEnabledBorder,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppPadding.p8),
              Obx(() {
                final sending = controller.sending.value;
                return Material(
                  color: ColorManager.colorPrimary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: sending ? null : controller.sendReply,
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: sending
                            ? const SizedBox(
                                width: 32,
                                height: 16,
                                child: AppLoader.dots(
                                  size: 16,
                                  color: Colors.white,
                                ),
                              )
                            // أيقونة send تنعكس تلقائيًا مع اتجاه النص.
                            : const Icon(
                                Icons.send_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
