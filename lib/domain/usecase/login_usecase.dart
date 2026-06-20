import '../../data/model/login_response_model.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResponseModel> call({required String username, required String password}) async {
    return await repository.login(username: username, password: password);
  }
}
