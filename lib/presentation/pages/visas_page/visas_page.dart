import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_request_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/compact_add_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/pages/visas_page/visas_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/visa_status_display.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class VisasPage extends GetView<VisasPageController> {
  const VisasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: CompactAddButton(
        label: "visas_apply_button".tr,
        onTap: () => Get.toNamed(AppRoutes.visaCountriesRoute),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.reload,
          child: Obx(() => _body()),
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
            padding: const EdgeInsets.only(top: 120),
            child: ErrorPlaceholderWidget(title: "visas_error_title".tr),
          ),
        ],
      );
    }

    if (state == LoadingState.doneWithNoData) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppPadding.p16,
              80,
              AppPadding.p16,
              AppPadding.p16,
            ),
            child: EmptyStateWidget(
              icon: Icons.badge_outlined,
              title: "visas_empty_title".tr,
              subtitle: "visas_empty_subtitle".tr,
              actionLabel: "visas_apply_button".tr,
              onAction: () => Get.toNamed(AppRoutes.visaCountriesRoute),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppPadding.p16,
        AppPadding.p16,
        AppPadding.p16,
        AppPadding.p16 + 48,
      ),
      itemCount:
          controller.requests.length + (controller.loadingMore.value ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p8),
      itemBuilder: (context, index) {
        if (index >= controller.requests.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppPadding.p16),
            child: AppLoader.dots(),
          );
        }
        return FadeSlideIn(
          delay: Duration(milliseconds: 40 * index.clamp(0, 8)),
          child: _VisaRequestCard(request: controller.requests[index]),
        );
      },
    );
  }
}

class _VisaRequestCard extends StatelessWidget {
  const _VisaRequestCard({required this.request});

  final VisaRequestModel request;

  @override
  Widget build(BuildContext context) {
    final status = VisaStatusDisplay.of(request.status);

    // الطلب المسحوب يُعرض تاريخ سحبه (القرار) إن وُجد، وإلا تاريخ التقديم.
    final isWithdrawn = request.status == "withdrawn";
    final stampDate = isWithdrawn
        ? (request.decidedAt ?? request.submittedAt)
        : request.submittedAt;
    final hasNote =
        (request.status == "needs_info" || request.status == "rejected") &&
        (request.adminNote?.isNotEmpty ?? false);
    final hasExtra =
        request.visaProviderName != null ||
        request.assignedAt != null ||
        request.deliveredAt != null ||
        hasNote;

    return CompactTripCard(
      onTap: () => Get.toNamed(
        AppRoutes.visaRequestDetailsRoute,
        arguments: {"requestId": request.id},
      ),
      title:
          request.country?.displayName ??
          "visas_fallback_title".trParams({"id": "${request.id}"}),
      badge: status.label,
      badgeColor: status.color,
      details: [
        if (stampDate != null)
          TextSpan(
            text: (isWithdrawn ? "visas_withdrawn_on" : "visas_submitted_on")
                .trParams({"date": DateFormat("d MMMM", "ar").format(stampDate)}),
          ),
        if (request.paymentMethod != null)
          TextSpan(
            text:
                "${stampDate != null ? " · " : ""}${VisaStatusDisplay.paymentLabel(request.paymentMethod!)}",
          ),
      ],
      price: Money.format(request.quotedAmount),
      extra: hasExtra
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (request.visaProviderName != null)
                      _Meta(
                        icon: Icons.business_outlined,
                        text: request.visaProviderName!,
                      ),
                    if (request.assignedAt != null)
                      _Meta(
                        icon: Icons.person_search_outlined,
                        text:
                            "${"visa_details_step_assigned".tr} • ${DateConverter.dateToStringAR(request.assignedAt)}",
                      ),
                    if (request.deliveredAt != null)
                      _Meta(
                        icon: Icons.check_circle_outline,
                        color: ColorManager.colorGreen3,
                        text:
                            "${"visa_details_step_delivered".tr} • ${DateConverter.dateToStringAR(request.deliveredAt)}",
                      ),
                  ],
                ),
                if (hasNote) ...[
                  const SizedBox(height: 6),
                  Text(
                    request.adminNote!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: status.color,
                    ),
                  ),
                ],
              ],
            )
          : null,
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? ColorManager.colorGrey6),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: FontSize.s12,
              color: color ?? ColorManager.colorDoveGray600,
            ),
          ),
        ),
      ],
    );
  }
}
