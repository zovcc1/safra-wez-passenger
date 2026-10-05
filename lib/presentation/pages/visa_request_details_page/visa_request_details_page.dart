import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_document_model.dart';
import 'package:safraa_passenger_app/data/models/visa_request_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_request_details_page/visa_request_details_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/visa_status_display.dart';

class VisaRequestDetailsPage extends GetView<VisaRequestDetailsPageController> {
  const VisaRequestDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorBackground,
      appBar: NormalAppBar(title: "visa_details_title".tr, backIcon: true),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.retry,
          child: Obx(() => _body()),
        ),
      ),
    );
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.loading || state == LoadingState.idle) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 120),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (state == LoadingState.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ErrorPlaceholderWidget(title: "visa_details_error_title".tr),
          ),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: AppButton(
              text: "common_retry".tr,
              onPressed: controller.retry,
            ),
          ),
        ],
      );
    }

    final request = controller.request.value!;
    final status = request.status;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        _StatusHeader(request: request),
        const SizedBox(height: AppPadding.p12),
        _InfoCard(request: request),
        // راجع القسم ٧ بالوثيقة: سبب الإلغاء cancelled داخلي فقط — الحقلان
        // الوحيدان اللذان يكتبان admin_note يراه الراكب هما request-correction
        // (needs_info) وreject (rejected). عرضه بحالة cancelled قد يظهر ملاحظة
        // قديمة من تصحيح سابق ويسبّب لبسًا بالضبط ما حذّرت منه الوثيقة.
        if ((status == "needs_info" || status == "rejected") &&
            (request.adminNote?.isNotEmpty ?? false)) ...[
          const SizedBox(height: AppPadding.p12),
          _AdminNoteCard(note: request.adminNote!, status: status),
        ],
        if (status == "delivered" && request.documents.isNotEmpty) ...[
          const SizedBox(height: AppPadding.p12),
          _DocumentsCard(documents: request.documents),
        ],
        if (request.allowedActions.isNotEmpty) ...[
          const SizedBox(height: AppPadding.p16),
          _ActionsRow(request: request),
        ],
      ],
    );
  }
}

class _CardFrame extends StatelessWidget {
  const _CardFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p12,
        vertical: AppPadding.p10,
      ),
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
      child: child,
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.request});

  final VisaRequestModel request;

  @override
  Widget build(BuildContext context) {
    final status = VisaStatusDisplay.of(request.status);
    return _CardFrame(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.badge_outlined, color: status.color, size: 20),
          ),
          const SizedBox(width: AppPadding.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: FontSize.s15,
                    fontWeight: FontWeight.bold,
                    color: status.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "#${request.id}",
                  style: TextStyle(
                    fontSize: FontSize.s13,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.colorGrey6,
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.request});

  final VisaRequestModel request;

  @override
  Widget build(BuildContext context) {
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                size: 18,
                color: ColorManager.colorPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                "visa_details_section_request".tr,
                style: TextStyle(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.p12),
          _InfoRow(
            label: "visa_details_country_label".tr,
            value: request.country?.displayName ?? "",
          ),
          const SizedBox(height: AppPadding.p8),
          _InfoRow(
            label: "visa_details_price_label".tr,
            value: request.expectedPrice,
          ),
          if (request.createdAt != null) ...[
            const SizedBox(height: AppPadding.p8),
            _InfoRow(
              label: "visa_details_created_at_label".tr,
              value:
                  "${DateConverter.dateToStringAR(request.createdAt)} ${DateConverter.timeUTCToString(request.createdAt)}",
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: FontSize.s13,
            color: ColorManager.colorGrey6,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: FontSize.s13,
            fontWeight: FontWeight.w600,
            color: ColorManager.colorFontPrimary,
          ),
        ),
      ],
    );
  }
}

class _AdminNoteCard extends StatelessWidget {
  const _AdminNoteCard({required this.note, required this.status});

  final String note;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = status == "rejected"
        ? ColorManager.colorError300
        : ColorManager.colorOrange;
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                status == "rejected"
                    ? "visa_details_rejection_reason_title".tr
                    : "visa_details_admin_note_title".tr,
                style: TextStyle(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.p8),
          // النص عربي دومًا (مزوَّد من صاحب المشروع)، يُعرض كما هو دون ترجمة.
          Text(
            note,
            style: TextStyle(fontSize: FontSize.s13, color: color),
          ),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({required this.documents});

  final List<VisaDocumentModel> documents;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaRequestDetailsPageController>();
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.download_outlined,
                size: 18,
                color: ColorManager.colorPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                "visa_details_documents_title".tr,
                style: TextStyle(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.p12),
          for (final document in documents)
            Obx(() {
              final downloading =
                  controller.downloadingDocumentId.value == document.documentId;
              return InkWell(
                onTap: downloading
                    ? null
                    : () => controller.downloadDocument(document),
                borderRadius: BorderRadius.circular(AppSize.s10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: ColorManager.colorGrey6,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          document.displayLabel,
                          style: TextStyle(
                            fontSize: FontSize.s13,
                            color: ColorManager.colorFontPrimary,
                          ),
                        ),
                      ),
                      if (downloading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.file_download_outlined,
                          size: 18,
                          color: ColorManager.colorPrimary,
                        ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.request});

  final VisaRequestModel request;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaRequestDetailsPageController>();
    final actions = request.allowedActions;

    return Column(
      children: [
        if (actions.contains("edit"))
          AppButton(
            text: "visa_details_action_edit".tr,
            radius: 12,
            minHeight: 42,
            onPressed: () => Get.toNamed(
              AppRoutes.visaRequestFormRoute,
              arguments: {
                "mode": "edit",
                "countryId": request.country?.id,
                "requestId": request.id,
              },
            ),
          ),
        if (actions.contains("resubmit")) ...[
          if (actions.contains("edit")) const SizedBox(height: AppPadding.p8),
          AppButton(
            text: "visa_details_action_resubmit".tr,
            radius: 12,
            minHeight: 42,
            onPressed: () => Get.toNamed(
              AppRoutes.visaRequestFormRoute,
              arguments: {
                "mode": "resubmit",
                "countryId": request.country?.id,
                "requestId": request.id,
              },
            ),
          ),
        ],
        if (actions.contains("withdraw")) ...[
          if (actions.contains("edit") || actions.contains("resubmit"))
            const SizedBox(height: AppPadding.p8),
          Obx(
            () => AppButton(
              text: "visa_details_action_withdraw".tr,
              backgroundColor: ColorManager.colorError300.withValues(
                alpha: 0.08,
              ),
              fontColor: ColorManager.colorError300,
              border: Border.all(
                color: ColorManager.colorError300.withValues(alpha: 0.4),
              ),
              radius: 12,
              minHeight: 42,
              loadingMode: controller.withdrawing.value,
              onPressed: () => _confirmWithdraw(controller),
            ),
          ),
        ],
      ],
    );
  }

  void _confirmWithdraw(VisaRequestDetailsPageController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: ColorManager.colorWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "visa_details_withdraw_confirm_title".tr,
                style: TextStyle(
                  fontSize: FontSize.s16,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
              const SizedBox(height: AppPadding.p8),
              Text(
                "visa_details_withdraw_confirm_message".tr,
                style: TextStyle(
                  fontSize: FontSize.s13,
                  color: ColorManager.colorGrey6,
                ),
              ),
              const SizedBox(height: AppPadding.p20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: "common_cancel".tr,
                      backgroundColor: ColorManager.colorBackground,
                      fontColor: ColorManager.colorFontPrimary,
                      radius: 12,
                      minHeight: 42,
                      onPressed: Get.back,
                    ),
                  ),
                  const SizedBox(width: AppPadding.p12),
                  Expanded(
                    child: AppButton(
                      text: "common_confirm".tr,
                      backgroundColor: ColorManager.colorError300,
                      radius: 12,
                      minHeight: 42,
                      onPressed: () {
                        Get.back();
                        controller.withdraw();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
