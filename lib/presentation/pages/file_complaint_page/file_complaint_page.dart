import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/complaint_category_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/custom_text_field.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/file_complaint_page/file_complaint_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/complaint_display.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class FileComplaintPage extends GetView<FileComplaintPageController> {
  const FileComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: NormalAppBar(title: "file_complaint_title".tr, backIcon: true),
        body: AppBackground(child: SafeArea(child: Obx(() => _body()))),
      ),
    );
  }

  Widget _body() {
    final state = controller.categoriesState.value;

    if (state == LoadingState.idle || state == LoadingState.loading) {
      return const AppLoader();
    }

    if (state == LoadingState.hasError) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ErrorPlaceholderWidget(
              title: "file_complaint_categories_error".tr,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: AppButton(
              text: "common_retry".tr,
              onPressed: controller.loadCategories,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppPadding.p16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideIn(child: const _IntroCard()),
                  if (controller.bookingId != null) ...[
                    const SizedBox(height: AppPadding.p8),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 50),
                      child: _BookingLinkBanner(
                        bookingId: controller.bookingId!,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppPadding.p8),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    child: _CardShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionLabel(
                            icon: Icons.category_outlined,
                            text: "file_complaint_category".tr,
                            required: true,
                          ),
                          const SizedBox(height: AppPadding.p4),
                          Text(
                            "file_complaint_category_hint".tr,
                            style: TextStyle(
                              fontSize: FontSize.s12,
                              color: ColorManager.colorGrey6,
                            ),
                          ),
                          const SizedBox(height: AppPadding.p8),
                          _CategoryGrid(controller: controller),
                          if (controller.categoryError.value)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppPadding.p8,
                              ),
                              child: Text(
                                "file_complaint_category_required".tr,
                                style: TextStyle(
                                  fontSize: FontSize.s12,
                                  color: ColorManager.colorError300,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppPadding.p8),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 160),
                    child: _CardShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionLabel(
                            icon: Icons.edit_note_rounded,
                            text: "file_complaint_description".tr,
                            required: true,
                          ),
                          const SizedBox(height: AppPadding.p8),
                          CustomTextField(
                            title: null,
                            hint: "file_complaint_description_hint".tr,
                            textEditingController:
                                controller.descriptionController,
                            textInputType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            fillColor: ColorManager.colorWhite,
                            borderRadius: 10,
                            maxLines: 5,
                            minLines: 5,
                            validator: controller.validateDescription,
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: _CharCounter(controller: controller),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _BottomBar(controller: controller),
      ],
    );
  }
}

/// غلاف الكارد المشترك — نفس ظل وحشوة بقية الشاشات.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppPadding.p10,
      ),
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(AppSize.s16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ColorManager.colorPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: ColorManager.colorPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppPadding.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "file_complaint_intro_title".tr,
                  style: TextStyle(
                    fontSize: FontSize.s15,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.colorFontPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "file_complaint_intro_subtitle".tr,
                  style: TextStyle(
                    fontSize: FontSize.s12,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.text,
    this.required = false,
  });

  final IconData icon;
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: FontSize.s13,
      fontWeight: FontWeight.w500,
      color: ColorManager.colorDoveGray600,
    );
    return Row(
      children: [
        Icon(icon, size: 18, color: ColorManager.colorPrimary),
        const SizedBox(width: AppPadding.p8),
        Text(text, style: style),
        if (required)
          Text(" *", style: style.copyWith(color: ColorManager.colorError300)),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.controller});

  final FileComplaintPageController controller;

  @override
  Widget build(BuildContext context) {
    // الـ Rx تُقرأ هنا داخل Obx مباشرة: itemBuilder يُنفَّذ لاحقًا وقت الـ layout
    // خارج نطاق تتبّع Obx، فقراءتها هناك لا تُعيد البناء عند تغيّر الاختيار.
    return Obx(() {
      final selectedKey = controller.selectedCategory.value;
      final categories = controller.categories.toList();
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppPadding.p8,
          crossAxisSpacing: AppPadding.p8,
          mainAxisExtent: 42,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryTile(
            category: category,
            label: category.labelFor(controller.lang),
            selected: selectedKey == category.key,
            onTap: () => controller.selectCategory(category.key),
          );
        },
      );
    });
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ComplaintCategoryModel category;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected
        ? ColorManager.colorPrimary
        : ColorManager.colorGrey6;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected
            ? ColorManager.colorPrimary.withValues(alpha: 0.06)
            : ColorManager.colorWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected
              ? ColorManager.colorPrimary
              : ColorManager.colorTextFieldEnabledBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p10),
            child: Row(
              children: [
                Icon(
                  complaintCategoryIcon(category.key),
                  size: 18,
                  color: accent,
                ),
                const SizedBox(width: AppPadding.p8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: FontSize.s12,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: selected
                          ? ColorManager.colorPrimary
                          : ColorManager.colorFontPrimary,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: ColorManager.colorPrimary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CharCounter extends StatelessWidget {
  const _CharCounter({required this.controller});

  final FileComplaintPageController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.descriptionController,
      builder: (context, value, _) {
        final length = value.text.trim().length;
        final over = length > FileComplaintPageController.descriptionMaxLength;
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "$length / ${FileComplaintPageController.descriptionMaxLength}",
            style: TextStyle(
              fontSize: FontSize.s11,
              color: over
                  ? ColorManager.colorError300
                  : ColorManager.colorGrey6,
            ),
          ),
        );
      },
    );
  }
}

class _BookingLinkBanner extends StatelessWidget {
  const _BookingLinkBanner({required this.bookingId});

  final int bookingId;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Row(
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: AppSize.s20,
            color: ColorManager.colorPrimary,
          ),
          const SizedBox(width: AppPadding.p8),
          Text(
            "file_complaint_linked_booking".trParams({"id": "$bookingId"}),
            style: TextStyle(
              fontSize: FontSize.s13,
              fontWeight: FontWeight.w500,
              color: ColorManager.colorPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final FileComplaintPageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p16,
        vertical: AppPadding.p12,
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
      child: Obx(
        () => AppButton(
          text: "file_complaint_submit".tr,
          radius: 12,
          minHeight: 42,
          loadingMode: controller.submitting.value,
          onPressed: controller.submit,
        ),
      ),
    );
  }
}
