class LoginResponseModel {
  final bool success;
  final UserInfo userInfo;
  final int fetchLimit;
  final ExamInfo? examInfo;

  LoginResponseModel({required this.success, required this.userInfo, required this.fetchLimit, this.examInfo});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json["success"] ?? false,
      userInfo: UserInfo.fromJson(json["user_info"]),
      fetchLimit: json["fetch_limit"] ?? 50,
      examInfo: json["exam_info"] != null ? ExamInfo.fromJson(json["exam_info"]) : null,
    );
  }
}

class UserInfo {
  final int id;
  final String username;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String contactMobile;
  final String contactEmail;
  final String roleName;
  final String isActive;
  final String isDeleted;

  UserInfo({
    required this.id,
    required this.username,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.contactMobile,
    required this.contactEmail,
    required this.roleName,
    required this.isActive,
    required this.isDeleted,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json["id"],
      username: json["username"] ?? "",
      firstName: json["first_name"] ?? "",
      middleName: json["middle_name"] ?? "",
      lastName: json["last_name"] ?? "",
      contactMobile: json["contact_mobile"] ?? "",
      contactEmail: json["contact_email"] ?? "",
      roleName: json["role_name"] ?? "",
      isActive: json["is_active"] ?? "",
      isDeleted: json["is_deleted"] ?? "",
    );
  }
}

class ExamInfo {
  final int id;
  final String examId;
  final String examDate;
  final String examStartTime;
  final String examEndTime;
  final String? remarks;
  final String createdAt;
  final String status;

  ExamInfo({
    required this.id,
    required this.examId,
    required this.examDate,
    required this.examStartTime,
    required this.examEndTime,
    required this.remarks,
    required this.createdAt,
    required this.status,
  });

  factory ExamInfo.fromJson(Map<String, dynamic> json) {
    return ExamInfo(
      id: json["id"],
      examId: json["exam_id"] ?? "",
      examDate: json["exam_date"] ?? "",
      examStartTime: json["exam_start_time"] ?? "",
      examEndTime: json["exam_end_time"] ?? "",
      remarks: json["remarks"] ?? "",
      createdAt: json["created_at"] ?? "",
      status: json["status"] ?? "",
    );
  }
}
