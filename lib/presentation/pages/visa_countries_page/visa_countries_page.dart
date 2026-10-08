import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/visa_country_model.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_background.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/empty_state_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/fade_slide_in.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/trip_card_widgets.dart';
import 'package:safraa_passenger_app/presentation/pages/visa_countries_page/visa_countries_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';
import 'package:safraa_passenger_app/presentation/util/money_formatter.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_loader.dart';

class VisaCountriesPage extends GetView<VisaCountriesPageController> {
  const VisaCountriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: NormalAppBar(title: "visa_countries_title".tr, backIcon: true),
      body: AppBackground(child: SafeArea(child: Obx(() => _body()))),
    );
  }

  Widget _body() {
    final state = controller.loadingState.value;

    if (state == LoadingState.idle || state == LoadingState.loading) {
      return const AppLoader();
    }

    if (state == LoadingState.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: ErrorPlaceholderWidget(
              title: "visa_countries_error_title".tr,
            ),
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

    if (state == LoadingState.doneWithNoData) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: EmptyStateWidget(
              icon: Icons.public_off_outlined,
              title: "visa_countries_empty_title".tr,
              subtitle: "visa_countries_empty_subtitle".tr,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppPadding.p16),
      itemCount: controller.countries.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppPadding.p8),
      itemBuilder: (context, index) => FadeSlideIn(
        delay: Duration(milliseconds: 40 * index.clamp(0, 8)),
        child: _CountryCard(country: controller.countries[index]),
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  const _CountryCard({required this.country});

  final VisaCountryModel country;

  @override
  Widget build(BuildContext context) {
    return TripCardShell(
      onTap: () => Get.toNamed(
        AppRoutes.visaRequestFormRoute,
        arguments: {
          "mode": "create",
          "countryId": country.id,
          "price": country.visaPrice,
        },
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ColorManager.colorPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.flag_outlined,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              country.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: FontSize.s14,
                fontWeight: FontWeight.w500,
                color: ColorManager.colorFontPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TripCardChip(
            icon: Icons.payments_outlined,
            color: ColorManager.colorPrimary,
            label: Money.format(country.visaPrice),
          ),
          const SizedBox(width: 8),
          const TripCardArrow(),
        ],
      ),
    );
  }
}
