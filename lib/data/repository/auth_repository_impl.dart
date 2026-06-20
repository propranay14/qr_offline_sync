import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../model/login_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<LoginResponseModel> login({required String username, required String password}) async {
    return await remoteDataSource.login(username: username, password: password);
  }
}
