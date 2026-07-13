import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/login_response_model.dart';

class SessionManager {
  SessionManager._();

  static const String isLoggedInKey = "is_logged_in";
  static const String loginResponseKey = "login_response";

  static Future<void> saveLoginSession(LoginResponseModel response) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(isLoggedInKey, true);
    await prefs.setString(loginResponseKey, jsonEncode(response.toJson()));
  }

  static Future<LoginResponseModel?> getLoginSession() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(loginResponseKey);

    if (data == null) return null;

    return LoginResponseModel.fromJson(jsonDecode(data));
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<String> getExamId() async {
    final session = await getLoginSession();
    return session?.examInfo?.examId ?? "";
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
