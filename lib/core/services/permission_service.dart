// import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
// import 'package:safraa_passenger_app/presentation/custom_widgets/custom_toasts.dart';

class PermissionService extends GetxService {
  // Future<bool> checkLocationServiceAndPermission({int retries = 2}) async {
  //   try {
  //     // Check if location services are enabled
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       CustomToasts(
  //         message: "LocationServicesDisabled".tr,
  //         type: CustomToastType.warning,
  //       ).show();
  //       // Prompt user to enable location services
  //       await Geolocator.openLocationSettings();
  //       // Retry a few times to check if user enabled location services
  //       for (int i = 0; i < retries; i++) {
  //         await Future.delayed(const Duration(seconds: 1));
  //         serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //         if (serviceEnabled) break;
  //       }
  //       if (!serviceEnabled) {
  //         CustomToasts(
  //           message: "PleaseEnableLocationServices".tr,
  //           type: CustomToastType.error,
  //         ).show();
  //         return false;
  //       }
  //     }

  //     // Check location permission
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         CustomToasts(
  //           message: "LocationPermissionDenied".tr,
  //           type: CustomToastType.warning,
  //         ).show();
  //         return false;
  //       }
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       CustomToasts(
  //         message: "LocationPermissionPermanentlyDenied".tr,
  //         type: CustomToastType.warning,
  //       ).show();
  //       // Optionally prompt user to open app settings
  //       await Geolocator.openAppSettings();
  //       return false;
  //     }

  //     return true;
  //   } catch (e) {
  //     CustomToasts(
  //       message: "ErrorCheckingLocationPermission".tr,
  //       type: CustomToastType.error,
  //     ).show();
  //     debugPrint('Error checking location permission: $e');
  //     return false;
  //   }
  // }

  /*
  Future<bool> storagePermission() async {
    if (Platform.isIOS) {
      return true;
    }
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    debugPrint('releaseVersion : ${androidInfo.version.release}');
    final int androidVersion = int.parse(androidInfo.version.release);
    bool havePermission = false;

    if (androidVersion >= 13) {
      final request = await [
        Permission.videos,
        Permission.photos,
        //..... as needed
      ].request();

      havePermission =
          request.values.every((status) => status == PermissionStatus.granted);
    } else {
      final status = await Permission.storage.request();
      havePermission = status.isGranted;
    }

    if (!havePermission) {
      // if no permission then open app-setting
      await openAppSettings();
    }

    return havePermission;
  }*/
  // Future<bool> checkLocationServiceAndPermission() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     await Geolocator.openLocationSettings();
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //   }

  //   if (permission == LocationPermission.denied) {
  //     return checkLocationServiceAndPermission();
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     await Get.dialog(
  //       AlertDialog(
  //         title: Text("Warning".tr, style: Get.textTheme.bodyLarge),
  //         content: Text('LocationServiceRequired'.tr),
  //         actions: [
  //           TextButton(
  //             onPressed: () async {
  //               await Geolocator.openAppSettings();
  //               Get.back();
  //             },
  //             child: Text(
  //               'OpenAppSetting'.tr,
  //               style: Get.textTheme.bodyMedium!.copyWith(
  //                 color: ColorManager.colorPrimary,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );

  //     return checkLocationServiceAndPermission();
  //   }

  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   return true;
  // }
}
