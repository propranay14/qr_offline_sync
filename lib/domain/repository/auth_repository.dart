import '../../data/model/login_response_model.dart';

abstract class AuthRepository {
  Future<LoginResponseModel> login({required String username, required String password});
}
