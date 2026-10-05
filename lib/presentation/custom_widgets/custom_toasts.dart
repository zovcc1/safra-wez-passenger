import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safraa_passenger_app/core/app/app.dart';
import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

enum CustomToastType { success, error, warning, delete }

class ToastContext {
  static BuildContext? context;
}

class CustomToasts {
  const CustomToasts({
    required this.message,
    required this.type,
    this.errorDetails,
    this.buttonName,
    this.buttonIcon,
    this.onTap,
    this.duration,
  });

  final String message;
  final CustomToastType type;
  final String? errorDetails;
  final String? buttonName;
  final String? buttonIcon;
  final void Function(FToast)? onTap;
  final Duration? duration;

  // void show() {
  //   FToast fToast = FToast();
  //   fToast.init(Get.overlayContext!);

  //   fToast.showToast(
  //     toastDuration: duration ?? const Duration(seconds: 4),
  //     child: Card(
  //       elevation: 1,
  //       child: Container(
  //         padding: const EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: ColorManager.colorToast,
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           //mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Row(
  //               children: [
  //                 SizedBox(
  //                   width: Get.width * 0.1,
  //                   child: Builder(
  //                     builder: (context) {
  //                       switch (type) {
  //                         case CustomToastType.success:
  //                           return const Icon(
  //                             Icons.circle_outlined,
  //                             color: Colors.green,
  //                           );
  //                         case CustomToastType.warning:
  //                           return const Icon(
  //                             Icons.warning_amber,
  //                             color: Colors.amber,
  //                           );
  //                         case CustomToastType.delete:
  //                           return Assets.icons.deleteIcon.svg(
  //                             width: 20,
  //                             height: 20,
  //                           );
  //                         case CustomToastType.error:
  //                           return const Icon(
  //                             Icons.cancel_outlined,
  //                             color: Colors.red,
  //                           );
  //                       }
  //                     },
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     SizedBox(
  //                       width: Get.width * 0.55,
  //                       child: Text(
  //                         message,
  //                         maxLines: 3,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.w500,
  //                           fontSize: 12,
  //                         ),
  //                       ),
  //                     ),
  //                     errorDetails == null
  //                         ? Container()
  //                         : SizedBox(
  //                             width: Get.width * 0.55,
  //                             child: Text(
  //                               errorDetails!,
  //                               maxLines: 3,
  //                               overflow: TextOverflow.ellipsis,
  //                               style: const TextStyle(
  //                                 fontWeight: FontWeight.w400,
  //                                 fontSize: 12,
  //                               ),
  //                             ),
  //                           ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             if (onTap != null)
  //               InkWell(
  //                 onTap: () {
  //                   onTap!(fToast);
  //                 },
  //                 child: Row(
  //                   children: [
  //                     SizedBox(
  //                       width: Get.width * 0.1,
  //                       child: Text(
  //                         buttonName ?? "",
  //                         style: TextStyle(
  //                           color: ColorManager.colorRed,
  //                           fontWeight: FontWeight.w600,
  //                           fontSize: 13,
  //                           decoration: TextDecoration.underline,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                     ),
  //                     if (buttonIcon != null)
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 1),
  //                         child: SvgPicture.asset(
  //                           buttonIcon!,
  //                           width: 16,
  //                           height: 16,
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     gravity: ToastGravity.BOTTOM,
  //   );
  // }

  void show({
    String? errorDetails,
    String? buttonName,
    String? buttonIcon,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    final overlayState = appNavigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('OverlayState is null');
      return;
    }
    OverlayEntry? entry;

    // entry?.remove();

    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 16,
        right: 16,
        bottom: 60,
        child: _ToastWidget(
          message: message,
          type: type,
          errorDetails: errorDetails,
          buttonName: buttonName,
          buttonIcon: buttonIcon,
          onTap: onTap,
        ),
      ),
    );

    overlayState.insert(entry);

    Future.delayed(duration, () {
      entry?.remove();
      entry = null;
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final CustomToastType type;
  final String? errorDetails;
  final String? buttonName;
  final String? buttonIcon;
  final VoidCallback? onTap;

  const _ToastWidget({
    required this.message,
    required this.type,
    this.errorDetails,
    this.buttonName,
    this.buttonIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _icon(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (errorDetails != null)
                      Text(
                        errorDetails!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (onTap != null)
                InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      buttonName ?? "",
                      style: TextStyle(
                        color: ColorManager.colorRed,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    switch (type) {
      case CustomToastType.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case CustomToastType.warning:
        return const Icon(Icons.warning_amber, color: Colors.amber);
      case CustomToastType.error:
        return const Icon(Icons.cancel, color: Colors.red);
      case CustomToastType.delete:
        return const Icon(Icons.delete, color: Colors.red);
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:safraa_passenger_app/presentation/util/resources/assets.gen.dart';
// import 'package:safraa_passenger_app/presentation/util/resources/color_manager.dart';

// enum CustomToastType { success, error, warning, delete }

// class CustomToasts {
//   const CustomToasts({
//     required this.message,
//     required this.type,
//     this.errorDetails,
//     this.buttonName,
//     this.buttonIcon,
//     this.onTap,
//     this.duration,
//   });

//   final String message;
//   final CustomToastType type;
//   final String? errorDetails;
//   final String? buttonName;
//   final String? buttonIcon;
//   final void Function(FToast)? onTap;
//   final Duration? duration;

//   void show() {
//     // Get.context is the Navigator's context (from GetMaterialApp),
//     // which always has an Overlay ancestor once the app is built.
//     // Unlike Get.overlayContext, it doesn't depend on a route being pushed yet.
//     final BuildContext? ctx = Get.context;

//     if (ctx == null) {
//       // App not built yet (e.g. called during app startup) — wait one frame and retry.
//       WidgetsBinding.instance.addPostFrameCallback((_) => show());
//       return;
//     }

//     _showToast(ctx);
//   }

//   void _showToast(BuildContext ctx) {
//     final FToast fToast = FToast();

//     try {
//       fToast.init(ctx);

//       fToast.showToast(
//         toastDuration: duration ?? const Duration(seconds: 4),
//         child: Card(
//           elevation: 1,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: ColorManager.colorToast,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: Get.width * 0.1,
//                       child: Builder(
//                         builder: (context) {
//                           switch (type) {
//                             case CustomToastType.success:
//                               return const Icon(
//                                 Icons.circle_outlined,
//                                 color: Colors.green,
//                               );
//                             case CustomToastType.warning:
//                               return const Icon(
//                                 Icons.warning_amber,
//                                 color: Colors.amber,
//                               );
//                             case CustomToastType.delete:
//                               return Assets.icons.deleteIcon.svg(
//                                 width: 20,
//                                 height: 20,
//                               );
//                             case CustomToastType.error:
//                               return const Icon(
//                                 Icons.cancel_outlined,
//                                 color: Colors.red,
//                               );
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: Get.width * 0.55,
//                           child: Text(
//                             message,
//                             maxLines: 3,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         errorDetails == null
//                             ? Container()
//                             : SizedBox(
//                                 width: Get.width * 0.55,
//                                 child: Text(
//                                   errorDetails!,
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w400,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 if (onTap != null)
//                   InkWell(
//                     onTap: () {
//                       onTap!(fToast);
//                     },
//                     child: Row(
//                       children: [
//                         SizedBox(
//                           width: Get.width * 0.1,
//                           child: Text(
//                             buttonName ?? "",
//                             style: TextStyle(
//                               color: ColorManager.colorRed,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 13,
//                               decoration: TextDecoration.underline,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//                         if (buttonIcon != null)
//                           Padding(
//                             padding: const EdgeInsets.only(left: 1),
//                             child: SvgPicture.asset(
//                               buttonIcon!,
//                               width: 16,
//                               height: 16,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         gravity: ToastGravity.BOTTOM,
//       );
//     } catch (e) {
//       debugPrint('CustomToasts error: $e');
//     }
//   }
// }
