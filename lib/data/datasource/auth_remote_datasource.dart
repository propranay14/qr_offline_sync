import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../model/login_response_model.dart';

class AuthRemoteDataSource {
  final Dio dio = ApiClient.dio;

  Future<LoginResponseModel> login({required String username, required String password}) async {
    final response = await dio.post(ApiConstants.login, data: {"username": username, "password": password});

    return LoginResponseModel.fromJson(response.data);
  }
}
