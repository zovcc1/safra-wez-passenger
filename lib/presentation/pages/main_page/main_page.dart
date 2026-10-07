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
import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
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
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _MainAppBar(controller: controller),
      body: Builder(
        builder: (context) => Stack(
          children: [
            // الخلفية تنتهي عند منتصف ارتفاع الـ bottom nav bar
            Positioned.fill(
              bottom: MediaQuery.paddingOf(context).bottom / 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(
                      'assets/backgrounds/background_app.png',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      ColorManager.colorWhite.withValues(alpha: 0.75),
                      BlendMode.srcOver,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: controller.pageController,
                onPageChanged: (index) => controller.pageIndex.value = index,
                children: controller.tabs
                    .map((tab) => _tabMeta[tab]!.page)
                    .toList(),
              ),
            ),
          ],
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
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
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
          icon: Assets.icons.notificationIcon.svg(
            width: 26,
            height: 26,
            colorFilter: ColorFilter.mode(
              ColorManager.colorFontPrimary,
              BlendMode.srcIn,
            ),
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
            color: ColorManager.colorBlack.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppPadding.p8,
        0,
        AppPadding.p8,
        AppPadding.p8,
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final count = controller.tabs.length;
          final activeIndex = controller.pageIndex.value;
          // x في AlignmentDirectional: -1 = بداية الصف، 1 = نهايته (يتبع RTL تلقائيًا).
          final x = count <= 1 ? 0.0 : -1 + 2 * activeIndex / (count - 1);
          return SizedBox(
            height: 68,
            child: Stack(
              children: [
                Positioned.fill(
                  top: AppPadding.p8,
                  child: Stack(
                    children: [
                      // شريط المؤشر: أعلى العنصر الحاوي للأيقونة، في منتصفه أفقيًا
                      AnimatedAlign(
                        alignment: AlignmentDirectional(x, -1),
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutBack,
                        child: FractionallySizedBox(
                          widthFactor: 1 / count,
                          heightFactor: 1,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 30,
                              height: 4,
                              decoration: BoxDecoration(
                                color: ColorManager.colorPrimary,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // الكبسولة المنزلقة خلف العنصر النشط
                      AnimatedAlign(
                        alignment: AlignmentDirectional(x, 0),
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutBack,
                        child: FractionallySizedBox(
                          widthFactor: 1 / count,
                          heightFactor: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: ColorManager.colorPrimary.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: controller.tabs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tab = entry.value;
                          final meta = MainPage._tabMeta[tab]!;
                          final isActive = activeIndex == index;
                          return Expanded(
                            child: _NavBarItem(
                              label: meta.label,
                              icon: isActive ? meta.activeIcon : meta.icon,
                              isActive: isActive,
                              onTap: () => controller.changePage(tab),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ارتداد (bounce) للأيقونة عند التفعيل
          AnimatedScale(
            scale: isActive ? 1.18 : 1.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(icon, key: ValueKey(icon), color: color, size: 24),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            style: DefaultTextStyle.of(context).style.copyWith(
              color: color,
              fontSize: FontSize.s11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
