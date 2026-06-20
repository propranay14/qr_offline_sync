class StudentModel {
  final int id;
  final String firstName;
  final String fatherName;
  final String lastName;
  final String profilePhoto;
  final String applicationNumber;
  final String biometricData;

  StudentModel({
    required this.id,
    required this.firstName,
    required this.fatherName,
    required this.lastName,
    required this.profilePhoto,
    required this.applicationNumber,
    required this.biometricData,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "firstName": firstName,
      "fatherName": fatherName,
      "lastName": lastName,
      "profilePhoto": profilePhoto,
      "applicationNumber": applicationNumber,
      "biometricData": biometricData,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map["id"],
      firstName: map["firstName"],
      fatherName: map["fatherName"],
      lastName: map["lastName"],
      profilePhoto: map["profilePhoto"],
      applicationNumber: map["applicationNumber"],
      biometricData: map["biometricData"],
    );
  }
}