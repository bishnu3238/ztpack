import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen<T extends UserEntity> extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onResetSuccess;
  final Function(String, String)? onOtpSent;

  const ForgotPasswordScreen({
    super.key,
    this.title = 'Forgot Password',
    this.subtitle = 'Enter your email or phone number to receive a reset code',
    this.onResetSuccess,
    this.onOtpSent,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState<T>();
}

class _ForgotPasswordScreenState<T extends UserEntity>
    extends State<ForgotPasswordScreen<T>> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _isEmailSelected = true;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      final authBloc = context.read<AuthBloc<T>>();
      authBloc.add(
        ForgotPasswordEvent(identifier: _identifierController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/images/support-call-svgrepo-com.svg',
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
                package: 'pack',
              ),
              onPressed: () {
                // Add support action here
              },
            ),
          ),
        ],
      ),
      body: BlocListener<AuthBloc<T>, AuthState<T>>(
        listener: (context, state) {
          if (state is PasswordResetSentState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Reset code sent. Please check your inbox or messages.',
                ),
                backgroundColor: Colors.green,
              ),
            );

            if (widget.onOtpSent != null) {
              widget.onOtpSent!(
                _identifierController.text.trim(),
                (state as PasswordResetSentState).userId,
              );
            }

            // Navigate to OTP verification screen
            // You'll need to create this screen or use your existing one
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => OTPVerificationScreen(
            //       identifier: _identifierController.text.trim(),
            //     ),
            //   ),
            // );

            widget.onResetSuccess?.call();
          } else if (state is AuthErrorState<T>) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App logo or illustration
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Option selector (Email or Phone)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEmailSelected = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      _isEmailSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.transparent,
                                ),
                                child: Text(
                                  'Email',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _isEmailSelected
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEmailSelected = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      !_isEmailSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Colors.transparent,
                                ),
                                child: Text(
                                  'Phone',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        !_isEmailSelected
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.onPrimary
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    AuthTextField(
                      label:
                          _isEmailSelected
                              ? 'Email Address *'
                              : 'Phone Number *',
                      hint:
                          _isEmailSelected
                              ? 'Enter your email address'
                              : 'Enter your phone number',
                      controller: _identifierController,
                      keyboardType:
                          _isEmailSelected
                              ? TextInputType.emailAddress
                              : TextInputType.phone,
                      prefixIcon: Icon(
                        _isEmailSelected
                            ? Icons.email_outlined
                            : Icons.phone_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _isEmailSelected
                              ? 'Please enter your email'
                              : 'Please enter your phone number';
                        }
                        if (_isEmailSelected &&
                            !RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        if (!_isEmailSelected &&
                            !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _resetPassword,
                    ),

                    const SizedBox(height: 32),

                    BlocBuilder<AuthBloc<T>, AuthState<T>>(
                      builder: (context, state) {
                        return AuthButton(
                          text: 'Send Reset Code',
                          onPressed: _resetPassword,
                          isLoading: state is AuthLoadingState,
                          icon: Icons.send_outlined,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
