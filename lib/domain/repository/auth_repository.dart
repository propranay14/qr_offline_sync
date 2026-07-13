import '../../data/model/login_response_model.dart';
import '../../data/model/operator_info_request_model.dart';

abstract class AuthRepository {
  Future<LoginResponseModel> login({required String username, required String password});

  Future<bool> updateOperatorInfo(OperatorInfoRequestModel model);
}
