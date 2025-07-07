import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import 'reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import 'reset_password_screen.dart';

class OTPScreen<T extends UserEntity> extends StatefulWidget {
  final String userId;
  final String userName;
  final String phoneNo;
  final String otp;

  final VoidCallback onVerifySuccess;
  const OTPScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.phoneNo,
    required this.otp,
    required this.onVerifySuccess,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState<T>();
}

class _OTPScreenState<T extends UserEntity> extends State<OTPScreen<T>> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _verifyOTP() {
    if (_formKey.currentState?.validate() ?? false) {
      final authBloc = context.read<AuthBloc<T>>();
      authBloc.add(
        VerifyOTPEvent(userId: widget.userId, otp: _otpController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: BlocListener<AuthBloc<T>, AuthState<T>>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            widget.onVerifySuccess.call();
          } else if (state is OTPVerifiedState<T>) {
            dev.log("hello");
            widget.onVerifySuccess.call();

            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder:
            //         (context) =>
            //             ResetPasswordScreen<T>(resetToken: state.resetToken),
            //   ),
            // );
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Enter OTP',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the OTP sent to ${widget.userName}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text('on ${widget.phoneNo}, OTP: ${widget.otp}'),
                  const SizedBox(height: 12),
                  AuthTextField(
                    label: 'OTP',
                    hint: 'Enter the 6-digit OTP',
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.verified_user),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.length != 6 ||
                          !RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'OTP must be a 6-digit number';
                      }
                      return null;
                    },
                    focusNode: _otpFocusNode,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _verifyOTP,
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc<T>, AuthState<T>>(
                    builder: (context, state) {
                      return AuthButton(
                        text: 'Verify OTP',
                        onPressed: _verifyOTP,
                        isLoading: state is AuthLoadingState,
                        icon: Icons.check_circle,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      final authBloc = context.read<AuthBloc<T>>();
                      authBloc.add(SendOTPEvent(phoneNo: widget.userId));
                    },
                    child: const Text('Resend OTP'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
