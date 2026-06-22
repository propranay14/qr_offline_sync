class CandidateSyncResponseModel {
  final bool success;
  final int count;
  final int nextCandidateId;
  final bool hasMore;
  final List<CandidateModel> data;

  CandidateSyncResponseModel({required this.success, required this.count, required this.nextCandidateId, required this.hasMore, required this.data});

  factory CandidateSyncResponseModel.fromJson(Map<String, dynamic> json) {
    return CandidateSyncResponseModel(
      success: json["success"] ?? false,
      count: json["count"] ?? 0,
      nextCandidateId: json["next_candidate_id"] ?? 0,
      hasMore: json["has_more"] ?? false,
      data: (json["data"] as List<dynamic>? ?? []).map((e) => CandidateModel.fromJson(e)).toList(),
    );
  }
}

class CandidateModel {
  final int id;
  final String candidateId;
  final String applicationId;
  final String candidateName;
  final String? fatherName;
  final String? motherName;
  final String gender;
  final String? dob;
  final String? mobileNo;
  final String? email;
  final String? addressLine1;
  final String? addressLine2;
  final String? villageCity;
  final String? district;
  final String? state;
  final String? pincode;
  final String? biometricStatus;

  /// Future-ready fields
  final String? profilePhoto;
  final String? fingerprintTemplate;
  final String? faceStatus;
  final String? fingerprintStatus;
  final String? updatedBy;
  final String? createdAt;

  final String updatedAt;

  CandidateModel({
    required this.id,
    required this.candidateId,
    required this.applicationId,
    required this.candidateName,
    this.fatherName,
    this.motherName,
    required this.gender,
    this.dob,
    this.mobileNo,
    this.email,
    this.addressLine1,
    this.addressLine2,
    this.villageCity,
    this.district,
    this.state,
    this.pincode,
    this.biometricStatus,
    this.profilePhoto,
    this.fingerprintTemplate,
    this.faceStatus,
    this.fingerprintStatus,
    this.updatedBy,
    this.createdAt,
    required this.updatedAt,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json["id"] ?? 0,
      candidateId: json["candidate_id"] ?? "",
      applicationId: json["application_id"] ?? "",
      candidateName: json["candidate_name"] ?? "",
      fatherName: json["father_name"],
      motherName: json["mother_name"],
      gender: json["gender"] ?? "",
      dob: json["dob"],
      mobileNo: json["mobile_no"],
      email: json["email"],
      addressLine1: json["address_line1"],
      addressLine2: json["address_line2"],
      villageCity: json["village_city"],
      district: json["district"],
      state: json["state"],
      pincode: json["pincode"],
      biometricStatus: json["biometric_status"],

      /// Future-safe parsing
      profilePhoto: json["profile_photo"],
      fingerprintTemplate: json["fingerprint_template"],
      faceStatus: json["face_status"],
      fingerprintStatus: json["fingerprint_status"],
      updatedBy: json["updated_by"],
      createdAt: json["created_at"],

      updatedAt: json["updated_at"] ?? "",
    );
  }

  factory CandidateModel.fromMap(Map<String, dynamic> map) {
    return CandidateModel(
      id: map["id"] ?? 0,
      candidateId: map["candidate_id"] ?? "",
      applicationId: map["application_id"] ?? "",
      candidateName: map["candidate_name"] ?? "",
      fatherName: map["father_name"],
      motherName: map["mother_name"],
      gender: map["gender"] ?? "",
      dob: map["dob"],
      mobileNo: map["mobile_no"],
      email: map["email"],
      addressLine1: map["address_line1"],
      addressLine2: map["address_line2"],
      villageCity: map["village_city"],
      district: map["district"],
      state: map["state"],
      pincode: map["pincode"],
      biometricStatus: map["biometric_status"],
      profilePhoto: map["profile_photo"],
      fingerprintTemplate: map["fingerprint_template"],
      faceStatus: map["face_status"],
      fingerprintStatus: map["fingerprint_status"],
      updatedBy: map["updated_by"],
      createdAt: map["created_at"],
      updatedAt: map["updated_at"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "candidate_id": candidateId,
      "application_id": applicationId,
      "candidate_name": candidateName,
      "father_name": fatherName,
      "mother_name": motherName,
      "gender": gender,
      "dob": dob,
      "mobile_no": mobileNo,
      "email": email,
      "address_line1": addressLine1,
      "address_line2": addressLine2,
      "village_city": villageCity,
      "district": district,
      "state": state,
      "pincode": pincode,
      "biometric_status": biometricStatus,

      /// New backend-ready fields
      "profile_photo": profilePhoto,
      "fingerprint_template": fingerprintTemplate,
      "face_status": faceStatus,
      "fingerprint_status": fingerprintStatus,
      "updated_by": updatedBy,
      "created_at": createdAt,

      "updated_at": updatedAt,

      /// Local-only fields
      "updated": 0,
      "photo_path": "",
      "fingerprint_data": "",
    };
  }
}
