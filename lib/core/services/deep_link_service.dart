import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

class DeepLinkService extends GetxService {
  static DeepLinkService get instance => Get.find<DeepLinkService>();

  bool _initUriCalled = false;

  @override
  void onInit() {
    super.onInit();
    debugPrint('DeepLinkService initialized');
  }

  void setInitUriCalled() {
    _initUriCalled = true;
  }

  bool get isInitUriCalled => _initUriCalled;

  Future<void> handleDeepLink(String route) async {
    if (route.isEmpty) {
      debugPrint('Empty route, going to main page');
      Get.offAllNamed(AppRoutes.mainRoute);
      return;
    }

    debugPrint('Attempting navigation to route: $route');

    List<String> routeParts = route
        .split('/')
        .where((part) => part.isNotEmpty)
        .toList();

    String baseRoute = routeParts[0];
    String id = '';

    if (routeParts.length > 1 && routeParts[1].isNotEmpty) {
      id = routeParts[1];
    }

    debugPrint('//////////////////////////////////////');
    debugPrint('BaseRoute ==> $baseRoute');
    debugPrint('id ==> $id');
    debugPrint('//////////////////////////////////////');

    if (Get.currentRoute != AppRoutes.mainRoute) {
      Get.offAllNamed(AppRoutes.mainRoute);
    }
    await Future.delayed(const Duration(seconds: 1));
    switch (baseRoute) {
      // case "ads":
      //   Get.toNamed(AppRoutes.detailsAdRoute, arguments: id);
      //   return;

      // case "stores":
      //   Get.toNamed(AppRoutes.detailsStoreRoute, arguments: id);
      //   return;

      // case "users":
      //   await Get.toNamed(AppRoutes.detailsUserRoute, arguments: id);
      //   return;

      // case "conversations":
      //   await Get.toNamed(AppRoutes.chatRoute, arguments: id);
      //   return;

      default:
        debugPrint('Unknown route: $baseRoute, navigating to main');
        await Get.toNamed(AppRoutes.mainRoute);
        return;
    }
  }
}
