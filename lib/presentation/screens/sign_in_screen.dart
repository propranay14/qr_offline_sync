import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_offline_sync/domain/usecase/validation_form.dart';

import '../../core/service/permission_service.dart';
import '../../core/widgets/custom_cta_button.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/usecase/login_usecase.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController(text: "operator1");
  final TextEditingController passwordController = TextEditingController(text: "operator1");

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final hasInternet = await PermissionService.hasInternet(context);
    if (!hasInternet) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final useCase = LoginUseCase(AuthRepositoryImpl(AuthRemoteDataSource()));

      final response = await useCase.call(username: usernameController.text.trim(), password: passwordController.text.trim());

      if (response.success) {
        debugPrint("Operator ID: ${response.userInfo.id}");
        debugPrint("Last Inserted ID: ${response.lastInsertedId}");

        Fluttertoast.showToast(msg: "Login successful");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Fluttertoast.showToast(msg: "Invalid credentials");
      }
    } catch (e) {
      debugPrint("Login Error: $e");
      Fluttertoast.showToast(msg: e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Title
                Text("Operator Login", style: TextStyle(fontSize: 32, color: colorScheme.primary)),
                const SizedBox(height: 32),

                /// Username
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    labelStyle: TextStyle(color: colorScheme.onSurface),
                    counterText: '',
                  ),
                  maxLength: 32,
                  style: TextStyle(color: colorScheme.onSurface),
                  validator: (value) => SignInValidator.validateUsername(value ?? '')?.errorMessage,
                ),
                const SizedBox(height: 20),

                /// Password
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    labelStyle: TextStyle(color: colorScheme.onSurface),
                    counterText: '',
                  ),
                  maxLength: 16,
                  style: TextStyle(color: colorScheme.onSurface),
                  obscureText: obscurePassword,
                  validator: (value) => SignInValidator.validatePassword(value ?? '')?.errorMessage,
                ),
                const SizedBox(height: 20),

                isLoading ? const CircularProgressIndicator() : CustomCtaButton(text: "Sign In", onPressed: signIn),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
