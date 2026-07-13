import '../../data/model/login_response_model.dart';
import '../../data/model/operator_info_request_model.dart';
import '../repository/auth_repository.dart';

class AuthUseCase {
  final AuthRepository repository;

  AuthUseCase(this.repository);

  Future<LoginResponseModel> call({required String username, required String password}) async {
    return await repository.login(username: username, password: password);
  }

  Future<bool> updateOperatorInfo(OperatorInfoRequestModel model) async {
    return await repository.updateOperatorInfo(model);
  }
}
