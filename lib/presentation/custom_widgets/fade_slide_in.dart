import 'package:flutter/material.dart';

/// حركة دخول هادئة (fade + slide خفيف للأعلى) لعناصر القوائم، مع إمكانية
/// تأخير كل عنصر عن الذي قبله لإنتاج أثر متدرّج (staggered) بسيط دون أي
/// حزمة خارجية.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 380),
    this.offset = 16,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final totalMs = duration.inMilliseconds + delay.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Curves.linear,
      builder: (context, value, child) {
        final raw =
            ((value * totalMs) - delay.inMilliseconds) /
            duration.inMilliseconds;
        final t = Curves.easeOutCubic.transform(raw.clamp(0.0, 1.0));
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * offset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
