class ApiConstants {
  ApiConstants._();

  /// Base URL
  static const String baseUrl = "https://biometric.requetech.in/";

  /// Auth
  static const String login = "api/login";

  /// Send Operator data after login
  static const String updateOperatorInfo = "api/updateOperatorInfo";

  /// Fetch Candidates
  static const String fetchCandidates = "api/syncCandidates";

  /// Sync Candidates to Server
  static const String updateCandidateBiometric = "api/updateCandidateBiometric";
}
