import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/presentation/custom_widgets/guest_gate_widget.dart';
import 'package:safraa_passenger_app/presentation/pages/bookings_page/bookings_page.dart';
import 'package:safraa_passenger_app/presentation/pages/main_page/main_page_controller.dart';
import 'package:safraa_passenger_app/presentation/pages/payment_requests_page/payment_requests_page.dart';
import 'package:safraa_passenger_app/presentation/pages/profile_page/profile_page.dart';
import 'package:safraa_passenger_app/presentation/pages/trips_page/trips_page.dart';
import 'package:safraa_passenger_app/presentation/pages/visas_page/visas_page.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';
import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

class MainPage extends GetView<MainPageController> {
  const MainPage({super.key});

  static bool get _isGuest => !Get.find<CacheService>().isLoggedIn();

  static Map<MainTab, _TabMeta> get _tabMeta => {
    MainTab.trips: _TabMeta(
      page: const TripsPage(),
      label: "main_tab_trips".tr,
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
    ),
    MainTab.bookings: _TabMeta(
      page: _isGuest
          ? const GuestGateWidget(
              icon: Icons.event_seat_outlined,
              titleKey: "guest_bookings_title",
              subtitleKey: "guest_bookings_subtitle",
            )
          : const BookingsPage(),
      label: "main_tab_bookings".tr,
      icon: Icons.event_seat_outlined,
      activeIcon: Icons.event_seat,
    ),
    MainTab.paymentRequests: _TabMeta(
      page: _isGuest
          ? const GuestGateWidget(
              icon: Icons.payments_outlined,
              titleKey: "guest_payments_title",
              subtitleKey: "guest_payments_subtitle",
            )
          : const PaymentRequestsPage(),
      label: "main_tab_payment_requests".tr,
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments,
    ),
    MainTab.visas: _TabMeta(
      page: _isGuest
          ? const GuestGateWidget(
              icon: Icons.badge_outlined,
              titleKey: "guest_visas_title",
              subtitleKey: "guest_visas_subtitle",
            )
          : const VisasPage(),
      label: "main_tab_visas".tr,
      icon: Icons.badge_outlined,
      activeIcon: Icons.badge,
    ),
    MainTab.profile: _TabMeta(
      page: _isGuest
          ? const GuestGateWidget(
              icon: Icons.person_outline,
              titleKey: "guest_profile_title",
              subtitleKey: "guest_profile_subtitle",
              showSettings: true,
            )
          : const ProfilePage(),
      label: "main_tab_profile".tr,
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.colorBackground,
      appBar: _MainAppBar(controller: controller),
      body: SafeArea(
        top: false,
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller.pageController,
          onPageChanged: (index) => controller.pageIndex.value = index,
          children: controller.tabs.map((tab) => _tabMeta[tab]!.page).toList(),
        ),
      ),
      bottomNavigationBar: _MainBottomNavBar(controller: controller),
    );
  }
}

class _TabMeta {
  final Widget page;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _TabMeta({
    required this.page,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class _MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MainAppBar({required this.controller});

  final MainPageController controller;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorManager.colorWhite,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      title: Obx(() {
        final tab = controller.tabs[controller.pageIndex.value];
        return Text(
          MainPage._tabMeta[tab]!.label,
          style: TextStyle(
            fontSize: FontSize.s18,
            fontWeight: FontWeight.bold,
            color: ColorManager.colorFontPrimary,
          ),
        );
      }),
      actions: [
        IconButton(
          onPressed: () {
            if (!Get.find<CacheService>().isLoggedIn()) {
              GuestGateWidget.promptLogin();
              return;
            }
            Get.toNamed(AppRoutes.notificationsRoute);
          },
          icon: Icon(
            Icons.notifications_none_outlined,
            color: ColorManager.colorFontPrimary,
          ),
          tooltip: "main_tab_notifications".tr,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MainBottomNavBar extends StatelessWidget {
  final MainPageController controller;

  const _MainBottomNavBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.colorWhite,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppPadding.p20),
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.colorBlack.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p8,
        vertical: AppPadding.p8,
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: controller.tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final meta = MainPage._tabMeta[tab]!;
              final isActive = controller.pageIndex.value == index;
              return _NavBarItem(
                label: meta.label,
                icon: isActive ? meta.activeIcon : meta.icon,
                isActive: isActive,
                onTap: () => controller.changePage(tab),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// StatelessWidget عادي بدون أي اعتماد على Rx — يستقبل isActive جاهزة كقيمة
/// بدل قراءتها بنفسه، لتجنّب مشكلة "Obx لا يكتشف Rx داخل ويدجت فرعي".
class _NavBarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? ColorManager.colorPrimary
        : ColorManager.colorGrey6;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppPadding.p12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p12,
          vertical: AppPadding.p8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: FontSize.s11),
            ),
          ],
        ),
      ),
    );
  }
}
