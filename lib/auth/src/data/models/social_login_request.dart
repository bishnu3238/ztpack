
// src/data/models/social_login_request.dart
class SocialLoginRequest {
  final String provider;
  final String token;
  final Map<String, dynamic>? userData;

  SocialLoginRequest({
    required this.provider,
    required this.token,
    this.userData,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'provider': provider,
      'token': token,
    };

    if (userData != null) {
      data['user_data'] = userData;
    }

    return data;
  }
}