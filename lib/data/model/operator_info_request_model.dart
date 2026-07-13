import 'package:dio/dio.dart';

class OperatorInfoRequestModel {
  final String examId;
  final String operatorId;
  final String geo;
  final String address;
  final String? photoPath;

  const OperatorInfoRequestModel({required this.examId, required this.operatorId, required this.geo, required this.address, this.photoPath});

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      "exam_id": examId,
      "operator_id": operatorId,
      "geo": geo,
      "address": address,
      if (photoPath != null && photoPath!.isNotEmpty) "photo": await MultipartFile.fromFile(photoPath!),
    });
  }

  Map<String, dynamic> toJson() {
    return {"exam_id": examId, "operator_id": operatorId, "geo": geo, "address": address};
  }
}
