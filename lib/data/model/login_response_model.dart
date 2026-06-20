class LoginResponseModel {
  final bool success;
  final UserInfoModel userInfo;
  final int lastInsertedId;

  LoginResponseModel({required this.success, required this.userInfo, required this.lastInsertedId});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json["success"] ?? false,
      userInfo: UserInfoModel.fromJson(json["user_info"] ?? {}),
      lastInsertedId: json["last_inserted_id"] ?? 0,
    );
  }
}

class UserInfoModel {
  final int id;
  final String isDeleted;
  final String isActive;
  final String username;
  final String password;
  final String firstName;
  final String middleName;
  final String lastName;
  final String contactMobile;
  final String contactEmail;
  final String roleName;

  UserInfoModel({
    required this.id,
    required this.isDeleted,
    required this.isActive,
    required this.username,
    required this.password,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.contactMobile,
    required this.contactEmail,
    required this.roleName,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json["id"] ?? 0,
      isDeleted: json["is_deleted"] ?? "",
      isActive: json["is_active"] ?? "",
      username: json["username"] ?? "",
      password: json["password"] ?? "",
      firstName: json["first_name"] ?? "",
      middleName: json["middle_name"] ?? "",
      lastName: json["last_name"] ?? "",
      contactMobile: json["contact_mobile"] ?? "",
      contactEmail: json["contact_email"] ?? "",
      roleName: json["role_name"] ?? "",
    );
  }
}
