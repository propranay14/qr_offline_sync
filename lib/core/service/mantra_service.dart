import 'package:flutter/services.dart';

class MantraService {
  static const MethodChannel _channel = MethodChannel('mantra_sdk');

  static Future<void> initialize() async {
    await _channel.invokeMethod('initScanner');
  }

  static Future<Map<String, dynamic>> capture() async {
    final result = await _channel.invokeMethod<Map>('captureFingerprint');

    return Map<String, dynamic>.from(result!);
  }

  static Future<void> dispose() async {
    await _channel.invokeMethod('disposeScanner');
  }
}
