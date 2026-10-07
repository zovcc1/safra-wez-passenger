import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_request_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/info_pill.dart';
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
      backgroundColor: ColorManager.colorBackground,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: ColorManager.colorPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: () => Get.toNamed(AppRoutes.visaCountriesRoute),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          "visas_apply_button".tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
        AppPadding.p16 + 64,
      ),
      itemCount:
          controller.requests.length + (controller.loadingMore.value ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p12),
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

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: ColorManager.colorWhite,
          borderRadius: BorderRadius.circular(AppSize.s16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSize.s16),
          onTap: () => Get.toNamed(
            AppRoutes.visaRequestDetailsRoute,
            arguments: {"requestId": request.id},
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: AppPadding.p10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: AppSize.s20,
                      color: ColorManager.colorPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.country?.displayName ??
                            "visas_fallback_title".trParams({
                              "id": "${request.id}",
                            }),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: FontSize.s15,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.colorFontPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontSize: FontSize.s10_5,
                          fontWeight: FontWeight.bold,
                          color: status.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppPadding.p8),
                Wrap(
                  spacing: AppPadding.p8,
                  runSpacing: AppPadding.p8,
                  children: [
                    InfoPill(icon: Icons.tag, text: "#${request.id}"),
                    if (request.submittedAt != null)
                      InfoPill(
                        icon: Icons.calendar_today_outlined,
                        text: DateConverter.dateToStringAR(request.submittedAt),
                      ),
                    if (request.paymentMethod != null)
                      InfoPill(
                        icon: Icons.account_balance_wallet_outlined,
                        text: VisaStatusDisplay.paymentLabel(
                          request.paymentMethod!,
                        ),
                      ),
                    if (request.visaProviderName != null)
                      InfoPill(
                        icon: Icons.business_outlined,
                        text: request.visaProviderName!,
                      ),
                    if (request.assignedAt != null)
                      InfoPill(
                        icon: Icons.person_search_outlined,
                        text:
                            "${"visa_details_step_assigned".tr} • ${DateConverter.dateToStringAR(request.assignedAt)}",
                      ),
                    if (request.deliveredAt != null)
                      InfoPill(
                        icon: Icons.check_circle_outline,
                        color: ColorManager.colorGreen3,
                        text:
                            "${"visa_details_step_delivered".tr} • ${DateConverter.dateToStringAR(request.deliveredAt)}",
                      ),
                  ],
                ),
                if ((request.status == "needs_info" ||
                        request.status == "rejected") &&
                    (request.adminNote?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: AppPadding.p8),
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
                const SizedBox(height: AppPadding.p8),
                Divider(
                  height: 1,
                  color: ColorManager.colorTextFieldEnabledBorder,
                ),
                const SizedBox(height: AppPadding.p8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        Money.format(request.quotedAmount),
                        style: TextStyle(
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.colorPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: ColorManager.colorGrey6,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
