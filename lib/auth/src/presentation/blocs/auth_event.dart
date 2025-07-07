// Events

enum OtpType{
  login, signup, forgetPassword, resetPassword,
}
abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String emailOrUsername;
  final String password;

  LoginEvent({
    required this.emailOrUsername,
    required this.password,
  });
}

class SignupEvent extends AuthEvent {
  final String email;
  final String phone;
  final String password;
  final String? name;

  SignupEvent({
    required this.email,
    required this.phone,
    required this.password,
    this.name,
  });
}



class ForgotPasswordEvent extends AuthEvent {
  final String identifier;

  ForgotPasswordEvent({
    required this.identifier,
  });
 
}

class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}

class SocialLoginEvent extends AuthEvent {
  final String provider;
  final String token;
  final Map<String, dynamic>? userData;

  SocialLoginEvent({
    required this.provider,
    required this.token,
    this.userData,
  });
}
class SendOTPEvent extends AuthEvent {
  final String phoneNo;
  SendOTPEvent({required this.phoneNo});
}

class VerifyOTPEvent extends AuthEvent {
  final String userId;
  final String otp;
  VerifyOTPEvent({required this.userId, required this.otp});
}

class ResetPasswordEvent extends AuthEvent {
  final String resetToken;
  final String newPassword;
  final String confirmPassword;
  ResetPasswordEvent({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });
}

class LogoutEvent extends AuthEvent {}