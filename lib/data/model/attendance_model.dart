class AttendanceModel {
  final String id;
  final String studentId;
  final String studentName;
  final String className;
  final String photoPath;
  final String fingerprintTemplate;
  final bool synced;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.photoPath,
    required this.fingerprintTemplate,
    required this.synced,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "studentId": studentId,
      "studentName": studentName,
      "className": className,
      "photoPath": photoPath,
      "fingerprintTemplate": fingerprintTemplate,
      "synced": synced ? 1 : 0,
    };
  }
}