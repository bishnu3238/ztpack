// src/presentation/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import '../widgets/background_connector.dart';
import 'login_screen.dart';

class SignupSuccessResult {
  final String id, name, phone, otp;
  SignupSuccessResult({
    required this.id,
    required this.name,
    required this.phone,
    this.otp = '',
  });
}

class SignupScreen<T extends UserEntity> extends StatefulWidget {
  final bool enableSocialLogin;
  final String? logoAsset;
  final String title;
  final String subtitle;
  final Function(SignupSuccessResult)? onSignupSuccess;
  final VoidCallback? onLoginTap;
  final bool requireName;
  final Color? accentColor;

  const SignupScreen({
    super.key,
    this.enableSocialLogin = false,
    this.logoAsset,
    this.title = 'Welcome',
    this.subtitle = 'Sign up to Explore the world of MyAD',
    this.onSignupSuccess,
    this.onLoginTap,
    this.requireName = true,
    this.accentColor,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState<T>();
}

class _SignupScreenState<T extends UserEntity> extends State<SignupScreen<T>> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get _isKeyboardVisible => MediaQuery.of(context).viewInsets.bottom > 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState?.validate() ?? false) {
      final authBloc = context.read<AuthBloc<T>>();
      authBloc.add(
        SignupEvent(
          name: widget.requireName ? _nameController.text.trim() : null,
          email: _emailController.text.trim(),
          phone: _phoneController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _socialLogin(SocialLoginProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          'Social signup with ${provider.name} is not implemented yet',
        ),
      ),
    );
  }

  Color get _accentColor => widget.accentColor ?? Theme.of(context).colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AuthBloc<T>, AuthState<T>>(
        listener: (context, state) {
          if (state is OTPSentState<T>) {
            final result = SignupSuccessResult(
              id: state.userId,
              name: _nameController.text,
              phone: _phoneController.text,
              otp: state.otp,
            );

            widget.onSignupSuccess?.call(result);
          }
          if (state is AuthenticatedState<T>) {
            widget.onSignupSuccess?.call(
              SignupSuccessResult(
                id: state.authResponse.user!.id,
                name: state.authResponse.user!.name,
                phone: '',
              ),
            );
          } else if (state is AuthErrorState<T>) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Background elements
            Positioned.fill(
              child: BackgroundConnector(
                accentColor: _accentColor,
                isKeyboardVisible: _isKeyboardVisible,
                isDarkMode: isDarkMode,
              ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo and Top Illustration
                            _buildLogoSection(isDarkMode),

                            const SizedBox(height: 24),

                            // Title and Subtitle
                            _buildTitleSection(),

                            const SizedBox(height: 32),

                            // Form Fields
                            _buildFormFields(),

                            const SizedBox(height: 32),

                            // Signup Button
                            BlocBuilder<AuthBloc<T>, AuthState<T>>(
                              builder: (context, state) {
                                return AuthButton(
                                  text: 'Sign Up',
                                  onPressed: _signup,
                                  isLoading: state is AuthLoadingState,
                                  icon: Icons.app_registration,
                                  accentColor: _accentColor,
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Social Login Section
                            if (widget.enableSocialLogin) _buildSocialLoginSection(),

                            const SizedBox(height: 24),

                            // Sign In Link
                            _buildSignInSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Floating decoration
            if (!_isKeyboardVisible)
              Positioned(
                right: -50,
                top: size.height * 0.15,
                child: Opacity(
                  opacity: 0.7,
                  child: SvgPicture.asset(
                    'assets/images/connection-dots.svg',
                    width: 150,
                    colorFilter: ColorFilter.mode(
                      _accentColor.withOpacity(0.3),
                      BlendMode.srcIn,
                    ),
                    package: 'pack',
                  ),
                ),
              ),

            if (!_isKeyboardVisible)
              Positioned(
                left: -30,
                bottom: size.height * 0.1,
                child: Opacity(
                  opacity: 0.5,
                  child: SvgPicture.asset(
                    'assets/images/service-nodes.svg',
                    width: 120,
                    colorFilter: ColorFilter.mode(
                      _accentColor.withOpacity(0.25),
                      BlendMode.srcIn,
                    ),                    package: 'pack',

                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(bool isDarkMode) {
    if (widget.logoAsset != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
              gradient: LinearGradient(
                colors: [
                  _accentColor.withOpacity(0.1),
                  _accentColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Image.asset(widget.logoAsset!, width: 100, height: 100),
          ),
          const SizedBox(height: 16),
          SvgPicture.asset(
            'assets/images/service-connectors.svg',
            width: 200,
            height: 60,
            colorFilter: ColorFilter.mode(
              isDarkMode
                  ? _accentColor.withOpacity(0.3)
                  : _accentColor.withOpacity(0.2),
              BlendMode.srcIn,
            ),                    package: 'pack',

          ),
        ],
      );
    } else {
      return SizedBox.shrink();
      return SvgPicture.asset(
        'assets/images/signup-illustration.svg',
        width: 200,
        height: 120,                    package: 'pack',

      );
    }
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _accentColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        if (widget.requireName) ...[
          AuthTextField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameController,
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            focusNode: _nameFocusNode,
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              _phoneFocusNode.requestFocus();
            },
            accentColor: _accentColor,
          ),
          const SizedBox(height: 16),
        ],
        AuthTextField(
          label: 'Phone No',
          hint: 'Enter your phone no',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone no';
            }
            return null;
          },
          focusNode: _phoneFocusNode,
          textInputAction: TextInputAction.next,
          onEditingComplete: () {
            _emailFocusNode.requestFocus();
          },
          accentColor: _accentColor,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Email',
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
          focusNode: _emailFocusNode,
          textInputAction: TextInputAction.next,
          onEditingComplete: () {
            _passwordFocusNode.requestFocus();
          },
          accentColor: _accentColor,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Password',
          hint: 'Enter your password',
          controller: _passwordController,
          isPassword: true,
          prefixIcon: const Icon(Icons.lock_outline),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 3) {
              return 'Password must be at least 3 characters';
            }
            return null;
          },
          focusNode: _passwordFocusNode,
          textInputAction: TextInputAction.next,
          onEditingComplete: () {
            _confirmPasswordFocusNode.requestFocus();
          },
          accentColor: _accentColor,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          label: 'Confirm Password',
          hint: 'Confirm your password',
          controller: _confirmPasswordController,
          isPassword: true,
          prefixIcon: const Icon(Icons.lock_outline),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          focusNode: _confirmPasswordFocusNode,
          textInputAction: TextInputAction.done,
          onEditingComplete: _signup,
          accentColor: _accentColor,
        ),
      ],
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        const AuthDivider(text: 'OR CONTINUE WITH'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(SocialLoginProvider.google),
            const SizedBox(width: 16),
            _buildSocialButton(SocialLoginProvider.facebook),
            const SizedBox(width: 16),
            _buildSocialButton(SocialLoginProvider.twitter),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(SocialLoginProvider provider) {
    IconData icon;
    Color color;

    switch (provider) {
      case SocialLoginProvider.google:
        icon = Icons.g_mobiledata_rounded;
        color = Colors.red;
        break;
      case SocialLoginProvider.facebook:
        icon = Icons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case SocialLoginProvider.twitter:
        icon = Icons.chat_bubble_outline;
        color = const Color(0xFF1DA1F2);
        break;
      default:
        icon = Icons.link;
        color = Colors.grey;
    }

    return InkWell(
      onTap: () => _socialLogin(provider),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }

  Widget _buildSignInSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: widget.onLoginTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: _accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}