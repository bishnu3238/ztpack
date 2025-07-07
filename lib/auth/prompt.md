How to Use custom_auth Package to Its Full Potential
The custom_auth package is a generic type comprehensive authentication solution for Flutter applications. It leverages Clean Architecture, BLoC pattern, and dependency injection to provide a robust, scalable authentication system. Here's how to maximize its capabilities:

1. Initialization
   Purpose: Sets up the package with your API endpoints and configuration.
   How to Use:
   Call CustomAuth.init() in your main.dart before runApp().
   Provide json converter for user model.
   Configure it with your API base URL and customize endpoints if needed.
   Enable social login if required.
    ```dart
    import 'package:custom_auth/custom_auth.dart';
    
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CustomAuth.init(
    baseUrl: ApiConfig.authBaseUrl,
    userFromJson: UserModel.fromJson,
    loginEndpoint: ApiConfig.login,
    otpEndpoint: ApiConfig.otp,
    signupEndpoint: ApiConfig.signUp,
    changePasswordEndpoint: ApiConfig.changePassword,
    forgotPasswordEndpoint: ApiConfig.forgotPassword,
    logoutEndpoint: ApiConfig.logout,
    defaultTimeout: Duration(seconds: 50),

    enableSocialLogin: false,
  );

  DependencyInjector.setup();

  runApp(App());
}
    ```
2. Authentication Features
   Login: Use the pre-built LoginScreen or trigger LoginEvent manually.
   Signup: Use SignupScreen or SignupEvent.
   Forgot Password: Use ForgotPasswordScreen or ForgotPasswordEvent.
   Change Password: Use ChangePasswordScreen or ChangePasswordEvent.
   Social Login: Enable in init and use SocialLoginEvent.
   OTP Verification: Use SendOTPEvent and VerifyOTPEvent.
   Logout: Use LogoutEvent or CustomAuth.logout().

3. Using Pre-built UI Components
   Screens:
   LoginScreen: Customizable login UI.
   SignupScreen: Customizable signup UI.
   ForgotPasswordScreen: Password reset request UI.
   ChangePasswordScreen: Password update UI.
   Widgets:
   AuthButton: Styled button with loading state.
   AuthTextField: Styled text field with validation.
   SocialLoginButton: Buttons for Google, Facebook, Twitter.
    ```dart
    import 'package:custom_auth/custom_auth.dart';
     GoRoute(
      path: login,
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: LoginScreen<UserModel>(
              onLoginSuccess: () => context.go('/home'),
              onCreateAccountTap: () => context.push(register),
              onForgotPasswordTap: () => context.push(forgotPassword),
            ),
          ),
    ),
    GoRoute(
      path: register,
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(),
            child: SignupScreen<UserModel>(
              onSignupSuccess: (String userId) {
                dev.log(userId);

                return context.pushNamed(
                  '/OTP',
                  pathParameters: {'userID': userId},
                );
              },
              onLoginTap: () => context.push(login),
            ),
          ),
    ),
    GoRoute(
      path: forgotPassword,
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: ForgotPasswordScreen<UserModel>(
              onResetSuccess: () {
                context.go('/login');
              },
            ),
          ),
    ),
    GoRoute(
      path: resetPassword,
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: ChangePasswordScreen<UserModel>(
              onPasswordChanged: () {
                context.go('/home');
              },
            ),
          ),
    ),
    GoRoute(
      path: '$otp/:userID',
      name: otp.toUpperCase(),
      builder:
          (context, state) => BlocProvider.value(
            value: getIt<AuthBloc<UserModel>>(), // Fetch AuthBloc from getIt
            child: OTPScreen<UserModel>(
              userId: state.pathParameters['userID']!,
              otp: 'OTP',
              phoneNo: 'PHONE',
              userName: 'USERNAME',
              onVerifySuccess: () {
                dev.log('OTP verified successfully');
                context.go(HomeRoute.home);
              },
            ),
          ),
    ),
    ```
4. BLoC Pattern Integration
   AuthBloc: Central state management for authentication.
   Events: Trigger actions (e.g., LoginEvent, SignupEvent).
   States: Handle responses (e.g., AuthenticatedState, AuthErrorState).
   Example with manual event triggering:
    ```dart
      context.read<AuthBloc<UserModel>>().add(
        LoginEvent(
        emailOrUsername: 'user@example.com',
        password: 'password123',
        ),
       );
    ```

5. Dependency Injection
   ## GetIt: Access services anywhere using getIt<AuthBloc>() or getIt<LoginUseCase>().
   Customizable: Register additional dependencies if needed.
6. State Management
   Listen to AuthBloc states to handle UI updates:
   AuthLoadingState: Show loading indicator.
   AuthenticatedState: Navigate to home screen.
   AuthErrorState: Show error messages.
7. Secure Storage
   Automatically handles token and user data storage.
   Access current user with CustomAuth.getCurrentUser().
   ## Check authentication status with CustomAuth.isAuthenticated().
8. Provider Integration
   Use AuthProviderModel for simpler state management with ChangeNotifier.
   Example:
   ```dart
        Collapse
        
        Wrap
        
        Copy
        class MyApp extends StatelessWidget {
        @override
        Widget build(BuildContext context) {
        return ChangeNotifierProvider(
        create: (_) => AuthProviderModel<UserModel>(),
        child: Consumer<AuthProviderModel<UserModel>>(
        builder: (context, auth, _) {
        return MaterialApp(
        home: auth.isAuthenticated ? HomeScreen() : LoginScreen(),
        );
        },
        ),
        );
        }
        }
   ```
9. Error Handling
   Comprehensive error handling with AuthError model.
   Custom error messages from API mapped to UI.
10. Extending Functionality
    Add custom use cases by extending AuthRepository.
    Customize UI by modifying exported widgets/screens.
    Integrate with your API by matching response structures.
    README File Documentation
    Here's a README file for your custom_auth package:

markdown

Collapse

Wrap

Copy
# Custom Auth Package

A comprehensive Flutter authentication package built with Clean Architecture, BLoC pattern, and dependency injection. Supports login, signup, password management, OTP verification, and social login.

## Features
- **Authentication**: Login, Signup, Forgot Password, Change Password
- **OTP Verification**: Send and verify OTPs
- **Social Login**: Google, Facebook, Twitter (configurable)
- **Secure Storage**: Token and user data persistence
- **Pre-built UI**: Customizable screens and widgets
- **State Management**: BLoC pattern with provider support
- **Error Handling**: Robust error management

## Installation
1. Add to `pubspec.yaml`:
```yaml
dependencies:
  custom_auth:
    path: ./custom_auth
Run flutter pub get.
Usage
Initialization
Initialize the package in main.dart:

dart

Collapse

Wrap

Copy
import 'package:custom_auth/custom_auth.dart';

void main() async {
  await CustomAuth.init(
    baseUrl: 'http://your-api.com/api.php',
    enableSocialLogin: true,
    // Customize endpoints if needed
  );
  runApp(MyApp());
}
Using Pre-built Screens
Add login screen to your app:

dart

Collapse

Wrap

Copy
import 'package:custom_auth/custom_auth.dart';

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LoginScreen<UserModel>(
      enableSocialLogin: true,
      logoAsset: 'assets/logo.png',
      onLoginSuccess: () => Navigator.pushNamed(context, '/home'),
    ),
  ),
);
Available screens:

LoginScreen
SignupScreen
ForgotPasswordScreen
ChangePasswordScreen
Manual Authentication
Use AuthBloc for manual control:

dart

Collapse

Wrap

Copy
context.read<AuthBloc<UserModel>>().add(
  LoginEvent(
    emailOrUsername: 'user@example.com',
    password: 'password123',
  ),
);

// Listen to states
BlocListener<AuthBloc<T>, AuthState<T>>(
  listener: (context, state) {
    if (state is AuthenticatedState) {
      Navigator.pushNamed(context, '/home');
    } else if (state is AuthErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
)
Provider Usage
Use AuthProviderModel for simpler state management:

dart

Collapse

Wrap

Copy
ChangeNotifierProvider(
  create: (_) => AuthProviderModel<UserModel>(),
  child: Consumer<AuthProviderModel>(
    builder: (context, auth, _) {
      return auth.isAuthenticated ? HomeScreen() : LoginScreen();
    },
  ),
)
Available Methods
CustomAuth.isAuthenticated(): Check if user is logged in
CustomAuth.getCurrentUser(): Get current user data
CustomAuth.logout(): Logout the user
API Requirements
Your backend should support these endpoints:

POST /auth/login
POST /auth/signup
POST /auth/forgot-password
POST /auth/change-password
POST /auth/social-login (if enabled)
POST /auth/logout
POST /auth/otp-verify
Response format:

json

Collapse

Wrap

Copy
{
  "user": {
    "id": "1",
    "name": "John Doe",
    "email": "john@example.com"
  },
  "token": "auth_token"
}
Customization
UI: Modify src/presentation/screens and src/presentation/widgets
Endpoints: Pass custom endpoints in init()
Models: Extend User and AuthResponse in src/data/models
Use Cases: Add new use cases in src/domain/usecases
Dependencies
dio: HTTP client
flutter_bloc: State management
get_it: Dependency injection
flutter_secure_storage: Secure storage
Example
dart

Collapse

Wrap

Copy
import 'package:flutter/material.dart';
import 'package:custom_auth/custom_auth.dart';

void main() async {
  await CustomAuth.init(baseUrl: 'http://your-api.com/api.php');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(
        onLoginSuccess: () => print('Logged in!'),
      ),
    );
  }
}
Contributing
Fork the repository
Create your feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a pull request
License
MIT License - see LICENSE file for details.

text

Collapse

Wrap

Copy

### Maximizing Potential Tips
1. **Full Feature Set**: Use all screens and widgets for a consistent UI.
2. **API Integration**: Match your backend to the expected endpoints and response formats.
3. **State Management**: Combine BLoC with Provider for complex apps.
4. **Security**: Leverage secure storage and token handling.
5. **Customization**: Tailor the UI and add custom use cases as needed.

This package is powerful for apps needing robust authentication with minimal setup. Let me
   