import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/widgets/custom_cta_button.dart';
import '../../domain/usecase/validation_form.dart';
import 'home_screen.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                Text("Sign In", style: TextStyle(fontSize: 32, color: colorScheme.primary)),
                const SizedBox(height: 32),

                /// Email
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    labelStyle: TextStyle(color: colorScheme.onSurface),
                    counterText: '',
                  ),
                  maxLength: 32,
                  style: TextStyle(color: colorScheme.onSurface),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => SignInValidator.validateEmail(value ?? '')?.errorMessage,
                ),
                const SizedBox(height: 20),

                /// Password
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surface,
                    labelStyle: TextStyle(color: colorScheme.onSurface),
                    counterText: '',
                  ),
                  maxLength: 16,
                  style: TextStyle(color: colorScheme.onSurface),
                  obscureText: true,
                  validator: (value) => SignInValidator.validatePassword(value ?? '')?.errorMessage,
                ),
                const SizedBox(height: 16),

                /// CTA : Sign In Button
                CustomCtaButton(
                  text: "Sign In",
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Fluttertoast.showToast(msg: "Success");
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
