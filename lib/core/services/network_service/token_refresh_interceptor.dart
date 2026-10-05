import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:safraa_passenger_app/core/config/env.dart';
import 'package:safraa_passenger_app/core/services/cache_service.dart';
import 'package:safraa_passenger_app/core/services/network_service/api.dart';
import 'package:safraa_passenger_app/presentation/util/resources/navigation_manager.dart';

/// Handles 401s by rotating the access/refresh token pair, then retries the
/// request that triggered it.
///
/// `POST /auth/refresh` rotates the refresh token: reusing a consumed one is
/// treated as theft and destroys the whole session (every sibling token +
/// the server-side session row). Concurrent 401s must therefore share a
/// single in-flight refresh instead of each calling `/auth/refresh` on their
/// own — the second call would be a replay of a token the first call already
/// consumed. That's what `_refreshCompleter` guards.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({required this.cacheService})
    : _refreshDio = Dio(
        BaseOptions(
          baseUrl: Env.apiBaseUrl,
          connectTimeout: const Duration(milliseconds: 30 * 1000),
          receiveTimeout: const Duration(milliseconds: 30 * 1000),
        ),
      );

  final CacheService cacheService;

  // Separate, interceptor-free client so the refresh call itself can never
  // be intercepted and looped back into this class.
  final Dio _refreshDio;

  Completer<_RefreshResult>? _refreshCompleter;
  bool _loggingOut = false;

  static const _authPaths = [Api.login, Api.refresh];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestPath = err.requestOptions.path;
    final isAuthEndpoint = _authPaths.any(requestPath.contains);

    if (err.response?.statusCode != 401 || isAuthEndpoint) {
      return handler.next(err);
    }

    // ضيف بدون توكن: لا جلسة لننهيها ولا refresh لنجريه.
    if (!cacheService.isLoggedIn()) return handler.next(err);

    final refreshToken = await cacheService.getUserRefreshToken();
    if (refreshToken.isEmpty) {
      await _forceLogout();
      return handler.next(err);
    }

    final refreshResult = await _refresh(refreshToken);
    if (!refreshResult.success) {
      await _forceLogout(message: refreshResult.message);
      return handler.next(err);
    }

    try {
      final retried = await _retry(err.requestOptions);
      return handler.resolve(retried);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  Future<_RefreshResult> _refresh(String refreshToken) {
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    final completer = Completer<_RefreshResult>();
    _refreshCompleter = completer;

    _performRefresh(refreshToken).then((result) {
      completer.complete(result);
      _refreshCompleter = null;
    });

    return completer.future;
  }

  Future<_RefreshResult> _performRefresh(String refreshToken) async {
    try {
      final response = await _refreshDio.post(
        Api.refresh,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      final data = response.data['data'] as Map<String, dynamic>?;
      final newToken = data?['token'] as String?;
      final newRefreshToken = data?['refresh_token'] as String?;
      final expiresIn = data?['expires_in'] as int?;

      if (newToken == null || newRefreshToken == null) {
        return const _RefreshResult(success: false);
      }

      await cacheService.storeSession(
        token: newToken,
        refreshToken: newRefreshToken,
        expiresIn: expiresIn,
      );
      return const _RefreshResult(success: true);
    } on DioException catch (e) {
      // 401 = refresh token already consumed/replayed (session destroyed
      // server-side); 403 = an access token was sent where a refresh token
      // was expected. Both mean this session is dead either way.
      final message = (e.response?.data is Map)
          ? (e.response?.data['message'] as String?)
          : null;
      return _RefreshResult(success: false, message: message);
    }
  }

  // Note: if the original request was a multipart upload built from a
  // single-use file stream, retrying it here can fail because that stream
  // was already consumed by the first attempt. Callers that upload large
  // files should treat a post-refresh retry failure as "please retry the
  // upload" rather than a silent success.
  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await cacheService.getUserToken();
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    headers['Authorization'] = 'Bearer $token';

    return _refreshDio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
      ),
    );
  }

  Future<void> _forceLogout({String? message}) async {
    if (_loggingOut) return;
    _loggingOut = true;

    await cacheService.clearAll();
    getx.Get.offAllNamed(
      AppRoutes.loginRoute,
      arguments: message == null ? null : {"message": message},
    );

    _loggingOut = false;
  }
}

class _RefreshResult {
  final bool success;
  final String? message;

  const _RefreshResult({required this.success, this.message});
}
