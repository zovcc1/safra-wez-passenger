import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_document_model.dart';
import 'package:safraa_passenger_app/data/models/visa_field_model.dart';
import 'package:safraa_passenger_app/data/models/visa_request_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_request_details_page/visa_request_details_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/utils.dart';
import 'package:safraa_passenger_app/presentation/util/visa_status_display.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class VisaRequestDetailsPage extends GetView<VisaRequestDetailsPageController> {
  const VisaRequestDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NormalAppBar(title: "visa_details_title".tr, backIcon: true),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: controller.retry,
            child: Obx(() => _body()),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.loading || state == LoadingState.idle) {
      return const AppPageLoader();
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

    var delayMs = 0;
    Widget staggered(Widget child) {
      final widget = FadeSlideIn(
        delay: Duration(milliseconds: delayMs),
        child: child,
      );
      delayMs += 70;
      return widget;
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppPadding.p16),
      children: [
        staggered(_StatusHeader(request: request)),
        const SizedBox(height: AppPadding.p8),
        // راجع القسم ٧ بالوثيقة: سبب الإلغاء cancelled داخلي فقط — الحقلان
        // الوحيدان اللذان يكتبان admin_note يراه الراكب هما request-correction
        // (needs_info) وreject (rejected). عرضه بحالة cancelled قد يظهر ملاحظة
        // قديمة من تصحيح سابق ويسبّب لبسًا بالضبط ما حذّرت منه الوثيقة.
        if ((status == "needs_info" || status == "rejected") &&
            (request.adminNote?.isNotEmpty ?? false)) ...[
          staggered(_AdminNoteCard(note: request.adminNote!, status: status)),
          const SizedBox(height: AppPadding.p8),
        ],
        if (request.form != null && request.form!.fields.isNotEmpty) ...[
          staggered(_DataCard(request: request)),
          const SizedBox(height: AppPadding.p8),
        ],
        if (request.otherDocuments.isNotEmpty) ...[
          staggered(_DocumentsCard(documents: request.otherDocuments)),
          const SizedBox(height: AppPadding.p8),
        ],
        if (request.hasTimeline) ...[
          staggered(_TimelineCard(request: request)),
          const SizedBox(height: AppPadding.p8),
        ],
        if (request.canEdit || request.canResubmit || request.canWithdraw)
          staggered(_ActionsRow(request: request)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x121B2559),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// بطاقة الملخص: الدولة + الحالة + السعر وطريقة الدفع.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.request});

  final VisaRequestModel request;

  @override
  Widget build(BuildContext context) {
    final status = VisaStatusDisplay.of(request.status);
    final hasPayment = request.paymentMethod != null;
    final hasProvider = request.visaProviderName != null;
    return _CardFrame(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ColorManager.colorPrimary,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.country?.displayName ?? "#${request.id}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.colorFontPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "visa_details_request_number".trParams({
                        "id": "${request.id}",
                      }),
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(label: status.label, color: status.color),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ColorManager.colorPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "visa_details_price_label".tr,
                          style: TextStyle(
                            fontSize: 11,
                            color: ColorManager.colorGrey6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Money.format(request.quotedAmount),
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: ColorManager.colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasPayment || hasProvider) ...[
                    VerticalDivider(
                      width: 28,
                      thickness: 1,
                      color: ColorManager.colorPrimary.withValues(alpha: 0.15),
                    ),
                    Expanded(
                      child: _SummarySide(
                        icon: hasPayment
                            ? Icons.account_balance_wallet_outlined
                            : Icons.business_outlined,
                        title: hasPayment
                            ? _paymentLabel(request.paymentMethod!)
                            : request.visaProviderName!,
                        label: hasPayment
                            ? "payment_request_payment_method".tr
                            : "visa_details_provider_label".tr,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (hasPayment && hasProvider) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 18,
                  color: ColorManager.colorGrey6,
                ),
                const SizedBox(width: 8),
                Text(
                  "${"visa_details_provider_label".tr}: ",
                  style: TextStyle(
                    fontSize: 11,
                    color: ColorManager.colorGrey6,
                  ),
                ),
                Expanded(
                  child: Text(
                    request.visaProviderName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ColorManager.colorFontPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummarySide extends StatelessWidget {
  const _SummarySide({
    required this.icon,
    required this.title,
    required this.label,
  });

  final IconData icon;
  final String title;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: ColorManager.colorGrey6),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: ColorManager.colorGrey6),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

String _paymentLabel(String method) => switch (method) {
  "external" => "visa_payment_external".tr,
  "wallet" => "create_booking_payment_wallet_short".tr,
  "cash_on_delivery" => "create_booking_payment_cod_short".tr,
  _ => method,
};

String _dateTime(DateTime? date) => date == null
    ? "visa_details_no_value".tr
    : "${DateConverter.dateToStringAR(date)} "
          "${DateConverter.timeUTCToString(date)}";

String _fileSize(int? bytes) {
  if (bytes == null) return "";
  if (bytes < 1024) return "$bytes B";
  if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(0)} KB";
  return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ColorManager.colorPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: ColorManager.colorPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorManager.colorFontPrimary,
            ),
          ),
        ),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: ColorManager.colorBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing!,
              style: TextStyle(fontSize: 10.5, color: ColorManager.colorGrey6),
            ),
          ),
      ],
    );
  }
}

/// كل حقول النموذج مع القيم المرسلة (والملفات المرفوعة بمكان حقولها).
class _DataCard extends StatelessWidget {
  const _DataCard({required this.request});

  final VisaRequestModel request;

  @override
  Widget build(BuildContext context) {
    final form = request.form!;
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.assignment_outlined,
            title: "visa_details_section_request".tr,
            trailing: form.displayTitle.isEmpty ? null : form.displayTitle,
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < form.fields.length; i++)
            _FieldValueTile(
              request: request,
              field: form.fields[i],
              isLast: i == form.fields.length - 1,
            ),
        ],
      ),
    );
  }
}

class _FieldValueTile extends StatelessWidget {
  const _FieldValueTile({
    required this.request,
    required this.field,
    required this.isLast,
  });

  final VisaRequestModel request;
  final VisaFieldModel field;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    if (field.type == "file") {
      final docs = request.documents
          .where((d) => d.fieldId == field.fieldId)
          .toList();
      if (docs.isEmpty) {
        return _FieldRow(
          label: field.displayLabel,
          value: "visa_details_no_value".tr,
          muted: true,
          isLast: isLast,
        );
      }
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final doc in docs)
              _DocumentRow(document: doc, label: field.displayLabel),
          ],
        ),
      );
    }

    final raw = request.values[field.fieldId] ?? "";
    var display = raw;
    if (field.type == "select" && raw.isNotEmpty) {
      final match = field.options
          .where((o) => "${o["en"] ?? o["ar"] ?? ""}" == raw)
          .firstOrNull;
      if (match != null) display = Utils.parseLocalizedName(match);
    }
    return _FieldRow(
      label: field.displayLabel,
      value: display.isEmpty ? "visa_details_no_value".tr : display,
      muted: display.isEmpty,
      isLast: isLast,
    );
  }
}

/// صف حقل: الاسم رمادي في طرف والقيمة في الطرف الآخر، وخط سفلي فاصل.
class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    required this.isLast,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool isLast;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 9),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: ColorManager.colorTextFieldEnabledBorder.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: ColorManager.colorGrey6),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: muted
                    ? ColorManager.colorGrey6
                    : ColorManager.colorFontPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة ملف قابل للتنزيل (داخل بطاقة البيانات وبطاقة المستندات).
class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document, this.label});

  final VisaDocumentModel document;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaRequestDetailsPageController>();
    return Obx(() {
      final downloading =
          controller.downloadingDocumentId.value == document.documentId;
      final size = _fileSize(document.sizeBytes);
      final meta = [
        if (size.isNotEmpty) size,
        if (document.uploadedAt != null)
          DateConverter.dateToStringAR(document.uploadedAt),
      ].join(" • ");
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColorManager.colorTextFieldEnabledBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorManager.colorPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                (document.mimeType ?? "").startsWith("image/")
                    ? Icons.image_outlined
                    : Icons.description_outlined,
                size: 20,
                color: ColorManager.colorPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label != null) ...[
                    Text(
                      label!,
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      document.originalName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: ColorManager.colorFontPrimary,
                      ),
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorManager.colorGrey6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              customBorder: const CircleBorder(),
              onTap: downloading
                  ? null
                  : () => controller.downloadDocument(document),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ColorManager.colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: downloading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 14,
                          child: AppLoader.dots(size: 12, color: Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.download_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.request});

  final VisaRequestModel request;

  @override
  Widget build(BuildContext context) {
    final steps =
        <({IconData icon, String label, DateTime? date, Color color})>[
          if (request.submittedAt != null)
            (
              icon: Icons.send_rounded,
              label: "visa_details_step_submitted".tr,
              date: request.submittedAt,
              color: ColorManager.colorGrey6,
            ),
          if (request.assignedAt != null)
            (
              icon: Icons.person_search_outlined,
              label: "visa_details_step_assigned".tr,
              date: request.assignedAt,
              color: ColorManager.colorPrimary,
            ),
          if (request.decidedAt != null)
            (
              icon: Icons.gavel_rounded,
              label: "visa_details_step_decided".tr,
              date: request.decidedAt,
              color: ColorManager.colorOrange,
            ),
          if (request.deliveredAt != null)
            (
              icon: Icons.check_circle_outline,
              label: "visa_details_step_delivered".tr,
              date: request.deliveredAt,
              color: ColorManager.colorGreen3,
            ),
        ];

    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.history_rounded,
            title: "visa_details_timeline_title".tr,
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: steps[i].color.withValues(alpha: 0.13),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          steps[i].icon,
                          size: 17,
                          color: steps[i].color,
                        ),
                      ),
                      if (i != steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            color: ColorManager.colorTextFieldEnabledBorder,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 4,
                        bottom: i == steps.length - 1 ? 0 : 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i].label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: ColorManager.colorFontPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: ColorManager.colorGrey6,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _dateTime(steps[i].date),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: ColorManager.colorGrey6,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
              Icon(Icons.info_outline, size: AppSize.s20, color: color),
              const SizedBox(width: 8),
              Text(
                status == "rejected"
                    ? "visa_details_rejection_reason_title".tr
                    : "visa_details_admin_note_title".tr,
                style: TextStyle(
                  fontSize: FontSize.s15,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppPadding.p8),
          // النص عربي دومًا (مزوَّد من صاحب المشروع)، يُعرض كما هو دون ترجمة.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppPadding.p10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              note,
              style: TextStyle(
                fontSize: FontSize.s13,
                height: 1.4,
                color: ColorManager.colorFontPrimary,
              ),
            ),
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
    return _CardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionTitle(
            icon: Icons.download_outlined,
            title: "visa_details_documents_title".tr,
          ),
          const SizedBox(height: AppPadding.p10),
          for (var i = 0; i < documents.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p12,
                vertical: AppPadding.p8,
              ),
              decoration: BoxDecoration(
                color: ColorManager.colorBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _DocumentRow(document: documents[i]),
            ),
            if (i != documents.length - 1)
              const SizedBox(height: AppPadding.p8),
          ],
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
    return Column(
      children: [
        if (request.canEdit)
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
        if (request.canResubmit) ...[
          if (request.canEdit) const SizedBox(height: AppPadding.p8),
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
        if (request.canWithdraw) ...[
          if (request.canEdit || request.canResubmit)
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
                  fontWeight: FontWeight.w500,
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
