import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._();

  static const String isLoggedInKey = "is_logged_in";
  static const String loginResponseKey = "login_response";

  static Future<void> saveLoginSession(Map<String, dynamic> loginJson) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(isLoggedInKey, true);
    await prefs.setString(loginResponseKey, jsonEncode(loginJson));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<Map<String, dynamic>?> getLoginSession() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(loginResponseKey);

    if (data == null) return null;

    return jsonDecode(data);
  }

  static Future<String> getExamId() async {
    final session = await getLoginSession();
    return session?["exam_info"]?["exam_id"] ?? "";
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}