// src/data/models/login_request.dart
class LoginRequest {
  final String emailOrUsername;
  final String password;

  LoginRequest({required this.emailOrUsername, required this.password});

  Map<String, dynamic> toJson() {
    return {'identifier': emailOrUsername, 'password': password};
  }

  @override
  String toString() {
    return 'LoginRequest{identifier: $emailOrUsername, password: $password}';
  }
}
