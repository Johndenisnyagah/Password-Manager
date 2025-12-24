/// A service class for handling user authentication (account creation and login).
///
/// This service manages the user's session state (JWT) and basic account operations.
/// Note: The account password handled here is for authentication only and should
/// NOT be used for vault encryption (which uses a separate master password).
class AuthService {
  // In a real app, this would be the URL to your minimal backend.
  /// The base URL for the authentication API.
  final String baseUrl;
  String? _jwt;
  String? _currentEmail;

  /// Creates an [AuthService].
  ///
  /// [baseUrl] defaults to 'https://api.passm.io'.
  AuthService({this.baseUrl = 'https://api.passm.io'});

  /// Returns `true` if the user is currently authenticated (has a valid JWT).
  bool get isAuthenticated => _jwt != null;

  /// Returns the current JWT token, or `null` if not authenticated.
  String? get jwt => _jwt;

  /// Returns the email of the currently logged-in user.
  String? get currentEmail => _currentEmail;

  /// Registers a new user account.
  ///
  /// The [accountPassword] is used ONLY for authentication, never for vault encryption.
  ///
  /// [email] The user's email address.
  /// [accountPassword] The password for the account.
  Future<void> register(String email, String accountPassword) async {
    // Implementation would involve a POST request to /register
    // For now, we simulate success and set a mock JWT.
    _jwt = 'mock-jwt-${email.hashCode}';
    _currentEmail = email;
  }

  /// Logs in an existing user.
  ///
  /// [email] The user's email address.
  /// [accountPassword] The password for the account.
  Future<void> login(String email, String accountPassword) async {
    // Implementation would involve a POST request to /login
    // For now, we simulate success and set a mock JWT.
    _jwt = 'mock-jwt-${email.hashCode}';
    _currentEmail = email;
  }

  /// Logs out the current user and clears the session.
  void logout() {
    _jwt = null;
    _currentEmail = null;
  }
}
