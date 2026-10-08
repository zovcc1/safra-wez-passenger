import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/complaint_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/compact_add_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/complaints_page/complaints_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/complaint_display.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class ComplaintsPage extends GetView<ComplaintsPageController> {
  const ComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NormalAppBar(title: "complaints_title".tr, backIcon: true),
      floatingActionButton: CompactAddButton(
        label: "complaints_file_new".tr,
        onTap: controller.fileNew,
      ),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.reload,
            child: Obx(() => _body()),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.idle || state == LoadingState.loading) {
      return const AppPageLoader();
    }

    if (state == LoadingState.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ErrorPlaceholderWidget(title: "complaints_error_title".tr),
          ),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: AppButton(
              text: "common_retry".tr,
              onPressed: controller.reload,
            ),
          ),
        ],
      );
    }

    if (state == LoadingState.doneWithNoData) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: FadeSlideIn(
              child: EmptyStateWidget(
                icon: Icons.support_agent_outlined,
                title: "complaints_empty_title".tr,
                subtitle: "complaints_empty_subtitle".tr,
              ),
            ),
          ),
        ],
      );
    }

    // تُقرأ داخل Obx (لا داخل itemBuilder) كي تتحدّث أسماء التصنيفات عند وصولها.
    final labels = Map<String, String>.of(controller.categoryLabels);
    return ListView.separated(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppPadding.p16,
        AppPadding.p16,
        AppPadding.p16,
        72,
      ),
      itemCount:
          controller.complaints.length + (controller.loadingMore.value ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p8),
      itemBuilder: (context, index) {
        if (index >= controller.complaints.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppPadding.p16),
            child: Center(child: AppLoader.dots(size: 20)),
          );
        }
        final complaint = controller.complaints[index];
        return FadeSlideIn(
          delay: Duration(milliseconds: 40 * index.clamp(0, 8)),
          child: _ComplaintCard(
            complaint: complaint,
            categoryLabel: labels[complaint.category] ?? complaint.category,
            onTap: () => controller.openDetails(complaint),
          ),
        );
      },
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({
    required this.complaint,
    required this.categoryLabel,
    required this.onTap,
  });

  final ComplaintModel complaint;
  final String categoryLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = ComplaintStatusDisplay.of(complaint.status);
    return TripCardShell(
      onTap: onTap,
      // awaiting_passenger هي الحالة الوحيدة التي تطلب إجراءً من المسافر.
      borderColor: complaint.isAwaitingPassenger ? status.color : null,
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
          Text(
            complaint.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: FontSize.s12,
              height: 1.5,
              color: ColorManager.colorDoveGray600,
            ),
          ),
          const SizedBox(height: 8),
          const TripCardDivider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (complaint.isAwaitingPassenger)
                      TripCardChip(
                        icon: Icons.mark_chat_unread_outlined,
                        color: status.color,
                        label: "complaint_needs_reply".tr,
                      ),
                    TripCardChip(
                      icon: Icons.tag,
                      color: ColorManager.colorGrey6,
                      label: "${complaint.complaintId}",
                    ),
                    TripCardChip(
                      icon: Icons.calendar_today_outlined,
                      color: ColorManager.colorGrey6,
                      label: DateConverter.dateToStringAR(complaint.createdAt),
                    ),
                    if (complaint.bookingId != null)
                      TripCardChip(
                        icon: Icons.confirmation_number_outlined,
                        color: ColorManager.colorGrey6,
                        label: "${complaint.bookingId}",
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const TripCardArrow(),
            ],
          ),
        ],
      ),
    );
  }
}
