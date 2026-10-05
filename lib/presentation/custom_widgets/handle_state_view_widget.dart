// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:safraa_passenger_app/core/extensions/sliver_or_widget_extension.dart';
// import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
// import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';
// import 'package:safraa_passenger_app/presentation/util/resources/values_manager.dart';

// class HandleStateViewWidget extends StatelessWidget {
//   final LoadingState state;
//   final Widget dataWidget;
//   final Widget? errorWidget;
//   final Widget? emptyWidget;
//   final Widget? idleWidget;
//   final Widget? loadingWidget;
//   final bool? isSliver;
//   final void Function()? onTap;

//   const HandleStateViewWidget({
//     super.key,
//     required this.state,
//     required this.dataWidget,
//     this.isSliver = false,
//     this.errorWidget,
//     this.emptyWidget,
//     this.idleWidget,
//     this.loadingWidget,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final paddingTop = MediaQuery.of(context).padding.top;
//     final appBarHeight = kToolbarHeight;
//     final bottomNavBarHeight = kBottomNavigationBarHeight;

//     final availableHeight =
//         screenHeight -
//         paddingTop -
//         appBarHeight -
//         bottomNavBarHeight -
//         AppSize.sHeight * 0.3;
//     switch (state) {
//       case LoadingState.loading:
//         return loadingWidget ??
//             SizedBox(
//               height: AppSize.sHeight * 0.5,
//               child: Center(
//                 child: CircularProgressIndicator(
//                   color: ColorManager.colorPrimary,
//                 ),
//               ),
//             ).sliverIf(isSliver);

//       case LoadingState.hasError:
//         return errorWidget?.sliverIf(isSliver) ??
//             SizedBox(
//               height: availableHeight,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error, color: ColorManager.colorRed, size: 48),
//                   SizedBox(height: AppSize.s8),
//                   Text(
//                     "ErrorLoadingData".tr,
//                     style: Get.textTheme.bodyLarge?.copyWith(
//                       color: ColorManager.colorRed,
//                     ),
//                   ),
//                   if (onTap != null)
//                     GestureDetector(
//                       onTap: onTap,
//                       child: Column(
//                         children: [
//                           SizedBox(height: AppSize.s10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 "TryAgain".tr,
//                                 style: Get.textTheme.bodyLarge?.copyWith(
//                                   color: ColorManager.colorBlack,
//                                 ),
//                               ),
//                               SizedBox(width: AppSize.s8),
//                               Icon(
//                                 Icons.refresh,
//                                 color: ColorManager.colorBlack,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ).sliverIf(isSliver);

//       case LoadingState.doneWithNoData:
//         return emptyWidget?.sliverIf(isSliver) ??
//             SizedBox(
//               height: availableHeight,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Assets.icons.storeIcon.svg(
//                     width: AppSize.s40,
//                     colorFilter: ColorFilter.mode(
//                       ColorManager.colorBlack.withValues(alpha: 0.8),
//                       BlendMode.srcIn,
//                     ),
//                   ),
//                   SizedBox(height: AppSize.s8),
//                   Text("NoDataAvailable".tr, style: Get.textTheme.bodyLarge),
//                 ],
//               ),
//             ).sliverIf(isSliver);

//       case LoadingState.idle:
//         return idleWidget?.sliverIf(isSliver) ?? SizedBox().sliverIf(isSliver);

//       case LoadingState.doneWithData:
//         return dataWidget;
//     }
//   }
// }
