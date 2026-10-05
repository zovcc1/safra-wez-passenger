import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:safraa_passenger_app/core/config/env.dart';
import 'package:safraa_passenger_app/core/services/network_service/remote_api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RealtimeEvent {
  /// اسم القناة الكامل مع البادئة، مثال: private-trip.1.location
  final String channel;
  final String event;
  final Map<String, dynamic> data;

  const RealtimeEvent(this.channel, this.event, this.data);
}

/// عميل Pusher-protocol خفيف فوق Reverb (لا توجد حزمة Pusher تدعم host مخصصًا
/// بشكل موثوق على المنصتين). يستخدم نفس bearer token العادي.
///
/// ما لا يضمنه الخادم: كل deploy يقطع كل الـ sockets ولا يُعاد إرسال ما فات.
/// لذلك عند كل إعادة اتصال ناجحة يُطلَق [reconnected] ويجب على المستهلك جلب
/// اللقطة (snapshot) من جديد.
class RealtimeService extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  final events = StreamController<RealtimeEvent>.broadcast();
  final reconnected = StreamController<void>.broadcast();
  final connected = false.obs;

  /// قنوات رفضها الخادم (403): لا نعيد الاشتراك بها.
  final Set<String> _denied = {};
  final Set<String> _wanted = {};
  final Set<String> _subscribed = {};

  WebSocketChannel? _socket;
  StreamSubscription? _socketSub;
  String? _socketId;
  Timer? _reconnectTimer;
  int _attempt = 0;
  bool _closedByUs = false;
  bool _hasConnectedBefore = false;
  bool _connecting = false;

  bool get isConfigured => Env.reverbAppKey.isNotEmpty;

  /// يشترك بالقناة (بادئة private- تُضاف هنا). آمن للاستدعاء المتكرر.
  Future<void> subscribe(String name) async {
    if (!isConfigured) return;
    final channel = "private-$name";
    _wanted.add(channel);
    _denied.remove(channel);
    _closedByUs = false;
    if (_socketId == null) {
      await _connect();
    } else {
      await _subscribeChannel(channel);
    }
  }

  void unsubscribe(String name) {
    final channel = "private-$name";
    _wanted.remove(channel);
    if (_subscribed.remove(channel)) {
      _send({
        "event": "pusher:unsubscribe",
        "data": {"channel": channel},
      });
    }
    if (_wanted.isEmpty) disconnect();
  }

  void disconnect() {
    _closedByUs = true;
    _reconnectTimer?.cancel();
    _socketSub?.cancel();
    _socket?.sink.close();
    _socket = null;
    _socketId = null;
    _subscribed.clear();
    connected.value = false;
    _attempt = 0;
  }

  Future<void> _connect() async {
    if (_connecting || _socket != null) return;
    _connecting = true;
    try {
      final uri = Uri.parse(
        "wss://${Env.reverbHost}:443/app/${Env.reverbAppKey}"
        "?protocol=7&client=safraa-passenger&version=1.0",
      );
      final socket = WebSocketChannel.connect(uri);
      _socket = socket;
      _socketSub = socket.stream.listen(
        _onMessage,
        onDone: _onClosed,
        onError: (_) => _onClosed(),
      );
    } catch (_) {
      _onClosed();
    } finally {
      _connecting = false;
    }
  }

  void _onMessage(dynamic raw) {
    final Map<String, dynamic> msg;
    try {
      msg = Map<String, dynamic>.from(jsonDecode(raw as String) as Map);
    } catch (_) {
      return;
    }
    final event = msg["event"]?.toString() ?? "";
    final payload = _decodeData(msg["data"]);

    switch (event) {
      case "pusher:connection_established":
        _socketId = payload["socket_id"]?.toString();
        _attempt = 0;
        connected.value = true;
        if (_hasConnectedBefore) reconnected.add(null);
        _hasConnectedBefore = true;
        for (final channel in _wanted.toList()) {
          _subscribeChannel(channel);
        }
      case "pusher:ping":
        _send({"event": "pusher:pong", "data": {}});
      case "pusher:error":
        debugPrint("Reverb error: $payload");
      case "pusher_internal:subscription_succeeded":
        break;
      default:
        final channel = msg["channel"]?.toString();
        if (channel != null && !event.startsWith("pusher")) {
          events.add(RealtimeEvent(channel, event, payload));
        }
    }
  }

  Map<String, dynamic> _decodeData(dynamic data) {
    try {
      final decoded = data is String ? jsonDecode(data) : data;
      return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _subscribeChannel(String channel) async {
    final socketId = _socketId;
    if (socketId == null ||
        _subscribed.contains(channel) ||
        _denied.contains(channel)) {
      return;
    }
    try {
      final response = await _api.request(
        url: Env.broadcastingAuthUrl,
        method: Method.post,
        requiredToken: true,
        params: jsonEncode({"socket_id": socketId, "channel_name": channel}),
      );
      // الرد ليس بالـ envelope الموحّد: {"auth": "key:signature"}.
      final auth = (response.data as Map)["auth"];
      if (auth == null) return;
      _subscribed.add(channel);
      _send({
        "event": "pusher:subscribe",
        "data": {"auth": auth, "channel": channel},
      });
    } catch (e) {
      // 403 = ليست لك/غير موجودة/انتهى التتبع: لا فائدة من الإعادة.
      _denied.add(channel);
      debugPrint("Reverb subscribe denied for $channel: $e");
    }
  }

  void _send(Map<String, dynamic> message) {
    try {
      _socket?.sink.add(jsonEncode(message));
    } catch (_) {}
  }

  void _onClosed() {
    _socketSub?.cancel();
    _socket = null;
    _socketId = null;
    _subscribed.clear();
    connected.value = false;
    if (_closedByUs || _wanted.isEmpty) return;
    _attempt++;
    final seconds = (1 << (_attempt.clamp(1, 5))).clamp(2, 30);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: seconds), _connect);
  }

  @override
  void onClose() {
    disconnect();
    events.close();
    reconnected.close();
    super.onClose();
  }
}
