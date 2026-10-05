import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/data/dto/pickup_dto.dart';
import 'package:safraa_passenger_app/data/models/pickup_models.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

/// ورقة اختيار نقطة تجميع جديدة (تغيير نقطة الركوب).
abstract class CollectionPointSheet {
  static Future<PickupDto?> show(
    List<CollectionPointModel> points, {
    int? currentId,
  }) {
    return Get.bottomSheet<PickupDto>(
      SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: ColorManager.colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(AppPadding.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "booking_pickup_choose_point".tr,
                style: TextStyle(
                  fontSize: FontSize.s16,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.colorFontPrimary,
                ),
              ),
              const SizedBox(height: AppPadding.p8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: points.map((p) {
                    final selected = p.collectionPointId == currentId;
                    return ListTile(
                      leading: Icon(
                        Icons.pin_drop_outlined,
                        color: ColorManager.colorPrimary,
                      ),
                      title: Text(p.name),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle,
                              color: ColorManager.colorPrimary,
                            )
                          : null,
                      onTap: () => Get.back(
                        result: PickupDto.collectionPoint(p.collectionPointId),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
