import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safraa_passenger_app/data/enums/loading_state_enum.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/app_button.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/error_placeholder_widget.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/normal_app_bar.dart';
import 'package:safraa_passenger_app/presentation/pages/tracking_page/tracking_page_controller.dart';
import 'package:safraa_passenger_app/presentation/util/date_converter.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class TrackingPage extends GetView<TrackingPageController> {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorBackground,
      appBar: NormalAppBar(title: "tracking_title".tr, backIcon: true),
      body: Obx(() {
        final state = controller.loadingState.value;
        if (state == LoadingState.loading || state == LoadingState.idle) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state == LoadingState.hasError) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: ErrorPlaceholderWidget(title: "tracking_error_title".tr),
              ),
              Padding(
                padding: const EdgeInsets.all(AppPadding.p16),
                child: AppButton(
                  text: "common_retry".tr,
                  onPressed: controller.refreshAll,
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            Expanded(child: _map()),
            _InfoPanel(controller: controller),
          ],
        );
      }),
    );
  }

  Widget _map() {
    final pickup = controller.booking.value?.pickup;
    final vehicle = controller.position.value;

    final markers = <Marker>{
      if (pickup != null && pickup.hasCoordinates)
        Marker(
          markerId: const MarkerId("pickup"),
          position: LatLng(pickup.latitude!, pickup.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      if (vehicle != null)
        Marker(
          markerId: const MarkerId("vehicle"),
          position: LatLng(vehicle.latitude, vehicle.longitude),
          rotation: vehicle.heading ?? 0,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
    };

    final LatLng target = vehicle != null
        ? LatLng(vehicle.latitude, vehicle.longitude)
        : (pickup != null && pickup.hasCoordinates
              ? LatLng(pickup.latitude!, pickup.longitude!)
              : const LatLng(33.5138, 36.2765));

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: target, zoom: 14),
      onMapCreated: (c) => controller.mapController = c,
      markers: markers,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.controller});

  final TrackingPageController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final snapshot = controller.snapshot.value!;
      final ended = controller.endedReason.value;
      final eta = controller.etaMinutes.value;
      final last = controller.lastUpdate;
      final isFixed = snapshot.pickupMode == PickupMode.fixedPoint;

      String headline;
      if (ended != null) {
        headline = "tracking_ended_$ended".tr;
      } else if (controller.stopArrivedAt.value != null) {
        headline = "tracking_driver_arrived".tr;
      } else if (snapshot.tripStatus == "waiting") {
        headline = isFixed
            ? "tracking_fixed_waiting".tr
            : "tracking_phase_${snapshot.pickupPhase ?? "not_started"}".tr;
      } else if (eta != null) {
        headline = "tracking_eta".trParams({"minutes": "$eta"});
      } else {
        headline = "tracking_driver_on_the_way".tr;
      }

      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppPadding.p16),
          decoration: BoxDecoration(
            color: ColorManager.colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: TextStyle(
                  fontSize: FontSize.s16,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
              if (ended == null &&
                  controller.position.value == null &&
                  snapshot.tripStatus == "departed") ...[
                const SizedBox(height: 4),
                Text(
                  "tracking_no_position".tr,
                  style: TextStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.colorGrey6,
                  ),
                ),
              ],
              if (last != null) ...[
                const SizedBox(height: 4),
                Text(
                  "tracking_last_update".trParams({
                    "time": DateConverter.timeUTCToString(last),
                  }),
                  style: TextStyle(
                    fontSize: FontSize.s11,
                    color: ColorManager.colorGrey6,
                  ),
                ),
              ],
              if (!controller.realtime.isConfigured) ...[
                const SizedBox(height: 4),
                Text(
                  "tracking_live_unavailable".tr,
                  style: TextStyle(
                    fontSize: FontSize.s11,
                    color: ColorManager.colorGrey6,
                  ),
                ),
              ] else if (ended == null &&
                  !controller.realtime.connected.value) ...[
                const SizedBox(height: 4),
                Text(
                  "tracking_reconnecting".tr,
                  style: TextStyle(
                    fontSize: FontSize.s11,
                    color: ColorManager.colorOrange,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
