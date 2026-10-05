import 'dart:math';

/// UUID v4 بدون الاعتماد على حزمة خارجية — يكفي لمفتاح idempotency (راجع
/// القسم 9.1 من المواصفات: يُولَّد مرة واحدة لكل محاولة حجز/موافقة/رفض،
/// ويُعاد استخدامه عند إعادة المحاولة بعد فشل شبكي وليس عند محاولة جديدة).
String generateIdempotencyKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant

  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  return "${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}";
}
