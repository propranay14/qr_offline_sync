class SignInValidationError {
  final int errorCode;
  final String errorMessage;

  SignInValidationError(this.errorCode, this.errorMessage);
}

abstract class SignInValidator {
  static const int validationErrorCode = 1001;

  static SignInValidationError? validateUsername(String userName) {
    if (userName.trim().isEmpty) {
      return SignInValidationError(validationErrorCode, "Please enter your username.");
    }
    if (userName.length < 2) {
      return SignInValidationError(validationErrorCode, "Username must be at least 2 characters long.");
    }
    return null;
  }

  static SignInValidationError? validateEmail(String email) {
    if (email.isEmpty) {
      return SignInValidationError(validationErrorCode, "Please enter your email.");
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return SignInValidationError(validationErrorCode, "Please enter a valid email address.");
    }
    return null;
  }

  static SignInValidationError? validatePassword(String password) {
    if (password.isEmpty) {
      return SignInValidationError(validationErrorCode, "Please enter your password.");
    }
    if (password.length < 6 || password.length > 20) {
      return SignInValidationError(validationErrorCode, "Password must be 6-20 characters long.");
    }
    return null;
  }
}

class SignUpValidationError {
  final int errorCode;
  final String errorMessage;

  SignUpValidationError(this.errorCode, this.errorMessage);
}

abstract class SignUpValidator {
  static const int validationErrorCode = 1001;

  static SignUpValidationError? validateFirstName(String firstName) {
    if (firstName.trim().isEmpty) {
      return SignUpValidationError(validationErrorCode, "Please enter your first name.");
    }
    if (firstName.length < 2) {
      return SignUpValidationError(validationErrorCode, "First name must be at least 2 characters long.");
    }
    return null;
  }

  static SignUpValidationError? validateEmail(String email) {
    if (email.isEmpty) {
      return SignUpValidationError(validationErrorCode, "Please enter your email.");
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return SignUpValidationError(validationErrorCode, "Please enter a valid email address.");
    }
    return null;
  }

  static SignUpValidationError? validatePassword(String password) {
    if (password.isEmpty) {
      return SignUpValidationError(validationErrorCode, "Please enter a password.");
    }
    if (password.length < 6 || password.length > 20) {
      return SignUpValidationError(validationErrorCode, "Password must be 6-20 characters long.");
    }
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    if (!hasLetter || !hasNumber || !hasSpecialChar) {
      return SignUpValidationError(validationErrorCode, "Password must include letters, numbers, and special characters.");
    }
    return null;
  }

  static SignUpValidationError? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return SignUpValidationError(validationErrorCode, "Please confirm your password.");
    }
    if (password != confirmPassword) {
      return SignUpValidationError(validationErrorCode, "Passwords do not match.");
    }
    return null;
  }
}
