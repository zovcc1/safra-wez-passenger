import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/dto/submit_rating_dto.dart';
import 'package:safraa_passenger_app/data/models/booking_model.dart';
import 'package:safraa_passenger_app/data/repos/bookings_repo.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_text_field.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/star_rating_widget.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

/// نموذج تقييم الحجز: نجمتان منفصلتان (المزوّد، المركبة) + تعليق اختياري حتى
/// 255 حرف. عند النجاح يرجّع الحجز المحدَّث عبر [Get.back].
class BookingRatingSheet extends StatefulWidget {
  const BookingRatingSheet({super.key, required this.bookingId});

  final int bookingId;

  static Future<BookingModel?> show(int bookingId) =>
      Get.bottomSheet<BookingModel>(
        BookingRatingSheet(bookingId: bookingId),
        isScrollControlled: true,
        backgroundColor: ColorManager.colorWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSize.s16),
          ),
        ),
      );

  @override
  State<BookingRatingSheet> createState() => _BookingRatingSheetState();
}

class _BookingRatingSheetState extends State<BookingRatingSheet> {
  final _comment = TextEditingController();
  int _providerScore = 0;
  int _vehicleScore = 0;
  bool _submitting = false;
  bool _showScoreError = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_providerScore == 0 || _vehicleScore == 0) {
      setState(() => _showScoreError = true);
      return;
    }
    if (_comment.text.trim().length > 255) {
      CustomToasts(
        message: "rating_comment_too_long".tr,
        type: CustomToastType.error,
      ).show();
      return;
    }
    setState(() => _submitting = true);
    final response = await Get.find<BookingsRepo>().rate(
      widget.bookingId,
      SubmitRatingDto(
        providerScore: _providerScore,
        vehicleScore: _vehicleScore,
        comment: _comment.text,
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!response.success) {
      CustomToasts(
        message: response.getErrorMessage(),
        type: CustomToastType.error,
      ).show();
      return;
    }
    CustomToasts(
      message: "rating_success".tr,
      type: CustomToastType.success,
    ).show();
    Get.back(result: response.data);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppPadding.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star_outline_rounded,
                    size: AppSize.s20,
                    color: ColorManager.colorPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "rating_title".tr,
                    style: TextStyle(
                      fontSize: FontSize.s15,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.colorFontPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppPadding.p12),
              _ScoreRow(
                label: "rating_provider".tr,
                value: _providerScore,
                onChanged: (v) => setState(() => _providerScore = v),
              ),
              const SizedBox(height: AppPadding.p8),
              _ScoreRow(
                label: "rating_vehicle".tr,
                value: _vehicleScore,
                onChanged: (v) => setState(() => _vehicleScore = v),
              ),
              if (_showScoreError &&
                  (_providerScore == 0 || _vehicleScore == 0))
                Padding(
                  padding: const EdgeInsets.only(top: AppPadding.p8),
                  child: Text(
                    "rating_scores_required".tr,
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.colorError300,
                    ),
                  ),
                ),
              const SizedBox(height: AppPadding.p12),
              CustomTextField(
                title: "rating_comment".tr,
                hint: "rating_comment_hint".tr,
                textEditingController: _comment,
                textInputType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                fillColor: ColorManager.colorBackground,
                borderRadius: 10,
                maxLines: 3,
                minLines: 3,
              ),
              const SizedBox(height: AppPadding.p8),
              AppButton(
                text: "rating_submit".tr,
                radius: 12,
                minHeight: 42,
                loadingMode: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p12,
        vertical: AppPadding.p8,
      ),
      decoration: BoxDecoration(
        color: ColorManager.colorBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: FontSize.s13,
                fontWeight: FontWeight.w600,
                color: ColorManager.colorFontPrimary,
              ),
            ),
          ),
          StarRatingWidget(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
