class StudentModel {
  final String studentId;
  final String name;
  final String className;

  StudentModel({
    required this.studentId,
    required this.name,
    required this.className,
  });

  factory StudentModel.fromQr(String qrData) {
    final parts = qrData.split('|');

    return StudentModel(
      studentId: parts[0],
      name: parts[1],
      className: parts[2],
    );
  }
}