import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint("┌──────────────────────────────────────────────");
    debugPrint("│ API REQUEST");
    debugPrint("├ METHOD: ${options.method}");
    debugPrint("├ URL: ${options.uri}");
    debugPrint("├ HEADERS: ${options.headers}");

    if (options.data != null) {
      debugPrint("├ BODY: ${const JsonEncoder.withIndent('  ').convert(options.data)}");
    }

    debugPrint("└──────────────────────────────────────────────");

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint("┌──────────────────────────────────────────────");
    debugPrint("│ API RESPONSE");
    debugPrint("├ URL: ${response.requestOptions.uri}");
    debugPrint("├ STATUS CODE: ${response.statusCode}");

    if (response.data != null) {
      debugPrint("├ DATA: ${const JsonEncoder.withIndent('  ').convert(response.data)}");
    }

    debugPrint("└──────────────────────────────────────────────");

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint("┌──────────────────────────────────────────────");
    debugPrint("│ API ERROR");
    debugPrint("├ URL: ${err.requestOptions.uri}");
    debugPrint("├ MESSAGE: ${err.message}");
    debugPrint("├ STATUS CODE: ${err.response?.statusCode}");

    if (err.response?.data != null) {
      debugPrint("├ ERROR DATA: ${const JsonEncoder.withIndent('  ').convert(err.response?.data)}");
    }

    debugPrint("└──────────────────────────────────────────────");

    super.onError(err, handler);
  }
}
