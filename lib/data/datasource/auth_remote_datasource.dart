import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../model/login_response_model.dart';
import '../model/operator_info_request_model.dart';

class AuthRemoteDataSource {
  final Dio dio = ApiClient.dio;

  Future<LoginResponseModel> login({required String username, required String password}) async {
    final response = await dio.post(ApiConstants.login, data: {"username": username, "password": password});

    return LoginResponseModel.fromJson(response.data);
  }

  Future<bool> updateOperatorInfo(OperatorInfoRequestModel model) async {
    final formData = FormData.fromMap({
      "exam_id": model.examId,
      "operator_id": model.operatorId,
      "geo": model.geo,
      "address": model.address,
      if (model.photoPath != null) "photo": await MultipartFile.fromFile(model.photoPath!),
    });

    final response = await dio.post(
      ApiConstants.updateOperatorInfo,
      data: formData,
      options: Options(headers: {"Accept": "/", "User-Agent": "PostmanRuntime/7.54.0", "Cookie": "PHPSESSID=21576d5c329612e0d2dc64a5d26dc2ce"}),
    );
    return response.toString().contains("true") == true;
  }
}
