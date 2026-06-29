import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._();

  static const String isLoggedInKey = "is_logged_in";
  static const String operatorIdKey = "operator_id";
  static const String usernameKey = "username";
  static const String firstNameKey = "first_name";
  static const String middleNameKey = "middle_name";
  static const String lastNameKey = "last_name";
  static const String roleNameKey = "role_name";
  static const String mobileKey = "mobile";
  static const String emailKey = "email";
  static const String lastInsertedIdKey = "last_inserted_id";

  static Future<void> saveLoginSession({
    required int operatorId,
    required String username,
    required String firstName,
    required String middleName,
    required String lastName,
    required String roleName,
    required String mobile,
    required String email,
    // required int lastInsertedId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(isLoggedInKey, true);
    await prefs.setInt(operatorIdKey, operatorId);
    await prefs.setString(usernameKey, username);
    await prefs.setString(firstNameKey, firstName);
    await prefs.setString(middleNameKey, middleName);
    await prefs.setString(lastNameKey, lastName);
    await prefs.setString(roleNameKey, roleName);
    await prefs.setString(mobileKey, mobile);
    await prefs.setString(emailKey, email);
    // await prefs.setInt(lastInsertedIdKey, lastInsertedId);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<int> getOperatorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(operatorIdKey) ?? 0;
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey) ?? "";
  }

  static Future<String> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(firstNameKey) ?? "";
  }

  static Future<String> getMiddleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(middleNameKey) ?? "";
  }

  static Future<String> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastNameKey) ?? "";
  }

  static Future<String> getFullName() async {
    final first = await getFirstName();
    final middle = await getMiddleName();
    final last = await getLastName();

    return "$first $middle $last".trim();
  }

  static Future<String> getRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleNameKey) ?? "";
  }

  static Future<String> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(mobileKey) ?? "";
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(emailKey) ?? "";
  }

  static Future<int> getLastInsertedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(lastInsertedIdKey) ?? 0;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
