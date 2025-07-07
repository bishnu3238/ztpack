// src/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:pack/extensions/extensions.dart';
import 'dart:ui';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen<T extends UserEntity> extends StatefulWidget {
  final bool enableSocialLogin;
  final String? logoAsset;
  final String title;
  final String subtitle;
  final Color? accentColor;
  final String? backgroundImage;
  final bool useGlassmorphism;
  final AnimationStyle animationStyle;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onCreateAccountTap;
  final VoidCallback? onForgotPasswordTap;

  const LoginScreen({
    super.key,
    this.enableSocialLogin = false,
    this.logoAsset,
    this.title = 'Welcome Back',
    this.subtitle = 'Sign in to your account',
    this.accentColor,
    this.backgroundImage,
    this.useGlassmorphism = false,
    this.animationStyle = AnimationStyle.fade,
    this.onLoginSuccess,
    this.onCreateAccountTap,
    this.onForgotPasswordTap,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState<T>();
}

enum AnimationStyle { fade, slide, scale }

class _LoginScreenState<T extends UserEntity> extends State<LoginScreen<T>>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _emailFilled = false;
  bool _passwordFilled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Listen for text changes to update filled state
    _emailController.addListener(_updateEmailFilled);
    _passwordController.addListener(_updatePasswordFilled);

    // Listen for focus changes for better UX
    _emailFocusNode.addListener(_handleEmailFocusChange);
    _passwordFocusNode.addListener(_handlePasswordFocusChange);
  }

  void _updateEmailFilled() {
    setState(() {
      _emailFilled = _emailController.text.isNotEmpty;
    });
  }

  void _updatePasswordFilled() {
    setState(() {
      _passwordFilled = _passwordController.text.isNotEmpty;
    });
  }

  void _handleEmailFocusChange() {
    setState(() {});
  }

  void _handlePasswordFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateEmailFilled);
    _passwordController.removeListener(_updatePasswordFilled);
    _emailFocusNode.removeListener(_handleEmailFocusChange);
    _passwordFocusNode.removeListener(_handlePasswordFocusChange);

    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() {
    // Unfocus current field to dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      // Use the correct generic type T for AuthBloc
      final authBloc = context.read<AuthBloc<T>>();
      authBloc.add(
        LoginEvent(
          emailOrUsername: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      // Add vibration feedback
      HapticFeedback.lightImpact();
    } else {
      // Error vibration
      HapticFeedback.mediumImpact();
    }
  }

  void _socialLogin(SocialLoginProvider provider) {
    // Add vibration feedback
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Social login with ${provider.name} is not implemented yet',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAnimatedContent(Widget child) {
    switch (widget.animationStyle) {
      case AnimationStyle.fade:
        return FadeTransition(opacity: _fadeAnimation, child: child);
      case AnimationStyle.slide:
        return SlideTransition(position: _slideAnimation, child: child);
      case AnimationStyle.scale:
        return ScaleTransition(scale: _scaleAnimation, child: child);
    }
  }

  Widget _buildBackground() {
    final Color primaryColor =
        widget.accentColor ?? Theme.of(context).colorScheme.primary;

    if (widget.backgroundImage != null) {
      return ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, primaryColor.withValues(alpha: 0.8)],
            stops: const [0.3, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstOut,
        child: Image.asset(
          widget.backgroundImage!,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withValues(alpha: 0.1),
              primaryColor.withValues(alpha: 0.3),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildMainContent() {
    final primaryColor = widget.accentColor ?? context.colorScheme.primary;
     Widget content = Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.logoAsset != null) ...[
            Hero(
              tag: 'app_logo',
              child: Image.asset(widget.logoAsset!, width: 80, height: 80),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  widget.useGlassmorphism
                      ? Colors.white
                      : Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color:
                  widget.useGlassmorphism
                      ? Colors.white70
                      : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 40),
          AuthTextField(
            label: 'Email or Username',
            hint: 'Enter your email or username',
            controller: _emailController,
            keyboardType: TextInputType.text,
            prefixIcon: Icon(
              Icons.person_outline,
              color: _emailFocusNode.hasFocus ? primaryColor : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or username';
              }
              return null;
            },
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            onEditingComplete: () {
              _passwordFocusNode.requestFocus();
            },
            isFilled: _emailFilled,
            accentColor: primaryColor,
            useGlassMorphism: widget.useGlassmorphism,
          ),
          const SizedBox(height: 20),
          AuthTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            isPassword: true,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: _passwordFocusNode.hasFocus ? primaryColor : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.done,
            onEditingComplete: _login,
            isFilled: _passwordFilled,
            accentColor: primaryColor,
            useGlassMorphism: widget.useGlassmorphism,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPasswordTap,
              style: TextButton.styleFrom(
                foregroundColor:
                    widget.useGlassmorphism ? Colors.white : primaryColor,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 30),
          BlocBuilder<AuthBloc<T>, AuthState<T>>(
            builder: (context, state) {
              return AuthButton(
                text: 'Sign In',
                onPressed: _login,
                isLoading: state is AuthLoadingState,
                icon: Icons.login,
                accentColor: primaryColor,
                useGlassmorphism: widget.useGlassmorphism,
              );
            },
          ),
          const SizedBox(height: 20),
          if (widget.enableSocialLogin) ...[
            const AuthDivider(),
            const SizedBox(height: 20),
            SocialLoginButton(
              provider: SocialLoginProvider.google,
              onPressed: () => _socialLogin(SocialLoginProvider.google),
              useGlassmorphism: widget.useGlassmorphism,
            ),
            const SizedBox(height: 14),
            SocialLoginButton(
              provider: SocialLoginProvider.facebook,
              onPressed: () => _socialLogin(SocialLoginProvider.facebook),
              useGlassmorphism: widget.useGlassmorphism,
            ),
            const SizedBox(height: 14),
            SocialLoginButton(
              provider: SocialLoginProvider.twitter,
              onPressed: () => _socialLogin(SocialLoginProvider.twitter),
              useGlassmorphism: widget.useGlassmorphism,
            ),
          ],
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.useGlassmorphism ? Colors.white70 : null,
                ),
              ),
              TextButton(
                onPressed:
                    widget.onCreateAccountTap ??
                    () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const SignupScreen(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                style: TextButton.styleFrom(
                  foregroundColor:
                      widget.useGlassmorphism ? Colors.white : primaryColor,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: const Text('Create Account'),
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.useGlassmorphism) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: content,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      extendBodyBehindAppBar: widget.backgroundImage != null,
      body: BlocListener<AuthBloc<T>, AuthState<T>>(
        listener: (context, state) {
          if (state is AuthenticatedState<T>) {
            // Success vibration
            HapticFeedback.heavyImpact();
            widget.onLoginSuccess?.call();
          } else if (state is AuthErrorState<T>) {
            HapticFeedback.vibrate();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: 24.symmetricHV(0),
                    child: _buildAnimatedContent(_buildMainContent()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
