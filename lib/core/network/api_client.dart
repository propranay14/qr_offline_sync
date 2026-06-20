import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'logger_interceptor.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {"Content-Type": "application/json"},
    ),
  )..interceptors.add(LoggerInterceptor());
}
