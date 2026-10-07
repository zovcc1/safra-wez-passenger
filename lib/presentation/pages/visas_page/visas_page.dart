import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_request_model.dart';
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
      floatingActionButton: Material(
        color: ColorManager.colorPrimary,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.toNamed(AppRoutes.visaCountriesRoute),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  "visas_apply_button".tr,
                  style: TextStyle(
                    fontSize: FontSize.s12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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

    return TripCardShell(
      onTap: () => Get.toNamed(
        AppRoutes.visaRequestDetailsRoute,
        arguments: {"requestId": request.id},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorManager.colorPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  request.country?.displayName ??
                      "visas_fallback_title".trParams({"id": "${request.id}"}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSize.s15,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(label: status.label, color: status.color),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _Meta(
                icon: Icons.confirmation_number_outlined,
                text: "visas_fallback_title".trParams({"id": "${request.id}"}),
                strong: true,
              ),
              if (request.submittedAt != null)
                _Meta(
                  icon: Icons.calendar_today_rounded,
                  text: DateConverter.dateToStringAR(request.submittedAt),
                ),
              if (request.paymentMethod != null)
                _Meta(
                  icon: Icons.account_balance_wallet_outlined,
                  text: VisaStatusDisplay.paymentLabel(request.paymentMethod!),
                ),
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
          if ((request.status == "needs_info" ||
                  request.status == "rejected") &&
              (request.adminNote?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 6),
            Text(
              request.adminNote!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: FontSize.s12, color: status.color),
            ),
          ],
          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: ColorManager.colorTextFieldEnabledBorder.withValues(
              alpha: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  Money.format(request.quotedAmount),
                  style: TextStyle(
                    fontSize: FontSize.s15,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.colorPrimary,
                  ),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: ColorManager.colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.icon,
    required this.text,
    this.strong = false,
    this.color,
  });

  final IconData icon;
  final String text;
  final bool strong;
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
              fontWeight: strong ? FontWeight.w500 : FontWeight.w400,
              color: strong
                  ? ColorManager.colorFontPrimary
                  : (color ?? ColorManager.colorDoveGray600),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: FontSize.s10_5,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
