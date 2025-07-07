// src/data/models/signup_request.dart
class SignupRequest {
  final String email;
  final String password;
  final String phone;
  final String name;

  SignupRequest({
    required this.email,
    required this.password,
    required this.phone,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
    };

    return data;
  }
}
