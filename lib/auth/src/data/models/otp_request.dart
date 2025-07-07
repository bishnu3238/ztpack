// src/data/models/login_request.dart
class OtpRequest {
  final String otp;
  final String userId;

  OtpRequest({required this.otp, required this.userId});

  Map<String, dynamic> toJson() {
    return {'otp': otp, 'user_id': userId};
  }

  @override
  String toString() {
    return 'OtpRequest{otp: $otp, userId: $userId}';
  }
}
