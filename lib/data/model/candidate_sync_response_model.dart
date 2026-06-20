class CandidateSyncResponseModel {
  final bool success;
  final int count;
  final int nextCandidateId;
  final bool hasMore;
  final List<CandidateModel> data;

  CandidateSyncResponseModel({
    required this.success,
    required this.count,
    required this.nextCandidateId,
    required this.hasMore,
    required this.data,
  });

  factory CandidateSyncResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CandidateSyncResponseModel(
      success: json["success"] ?? false,
      count: json["count"] ?? 0,
      nextCandidateId: json["next_candidate_id"] ?? 0,
      hasMore: json["has_more"] ?? false,
      data: (json["data"] as List<dynamic>? ?? [])
          .map((e) => CandidateModel.fromJson(e))
          .toList(),
    );
  }
}

class CandidateModel {
  final int id;
  final String firstName;
  final String fatherName;
  final String lastName;
  final String applicationNumber;
  final String profilePhoto;
  final String biometricData;

  CandidateModel({
    required this.id,
    required this.firstName,
    required this.fatherName,
    required this.lastName,
    required this.applicationNumber,
    required this.profilePhoto,
    required this.biometricData,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json["id"] ?? 0,
      firstName: json["first_name"] ?? "",
      fatherName: json["father_name"] ?? "",
      lastName: json["last_name"] ?? "",
      applicationNumber: json["application_number"] ?? "",
      profilePhoto: json["profile_photo"] ?? "",
      biometricData: json["biometric_data"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "first_name": firstName,
      "father_name": fatherName,
      "last_name": lastName,
      "application_number": applicationNumber,
      "profile_photo": profilePhoto,
      "biometric_data": biometricData,
    };
  }
}