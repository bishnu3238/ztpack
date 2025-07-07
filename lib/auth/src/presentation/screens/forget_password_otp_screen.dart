import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pack/services/responsive_service/responsive_utils_advance.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/auth_button.dart';
import 'reset_password_screen.dart';

class OTPVerificationScreen<T extends UserEntity> extends StatefulWidget {
  final String identifier; // Email or phone
  final String userId; // If you have the user ID
  final int otpLength;
  final int otpExpiryMinutes;

  const OTPVerificationScreen({
    super.key,
    required this.identifier,
    required this.userId,
    this.otpLength = 6,
    this.otpExpiryMinutes = 5,
  });

  @override
  State<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState<T>();
}

class _OTPVerificationScreenState<T extends UserEntity>
    extends State<OTPVerificationScreen<T>> {
  final List<TextEditingController> _otpControllers = [];
  final List<FocusNode> _focusNodes = [];
  Timer? _countdownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Initialize controllers and focus nodes based on OTP length
    for (int i = 0; i < widget.otpLength; i++) {
      _otpControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    // Start countdown timer
    _startCountdownTimer();
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }

    // Cancel timer
    _countdownTimer?.cancel();

    super.dispose();
  }

  void _startCountdownTimer() {
    // Set initial countdown time
    _remainingSeconds = widget.otpExpiryMinutes * 60;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String get _formattedCountdown {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length == widget.otpLength) {
      final authBloc = context.read<AuthBloc<T>>();
      authBloc.add(VerifyOTPEvent(otp: otp, userId: widget.userId));
    }
  }

  void _resendOtp() {
    final authBloc = context.read<AuthBloc<T>>();
    authBloc.add(ForgotPasswordEvent(identifier: widget.identifier));

    // Reset countdown timer
    _startCountdownTimer();

    // Clear OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    if (_otpControllers.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: BlocListener<AuthBloc<T>, AuthState<T>>(
        listener: (context, state) {
          if (state is OTPVerifiedState<T>) {
            // Navigate to reset password screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ResetPasswordScreen<T>(resetToken: state.resetToken),
              ),
            );
          } else if (state is AuthErrorState<T>) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is PasswordResetSentState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('New OTP sent successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                Icon(
                  Icons.verified_outlined,
                  size: 70,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 24),

                Text(
                  'Verification Code',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'We\'ve sent a verification code to:',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  widget.identifier,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.otpLength,
                    (index) => Container(
                      width: ScreenUtils().getHorizontalSize(40),
                      height: ScreenUtils().getVerticalSize(40),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 24),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              index < widget.otpLength - 1) {
                            _focusNodes[index + 1].requestFocus();
                          }

                          // Auto-verify when all fields are filled
                          if (value.isNotEmpty &&
                              index == widget.otpLength - 1 &&
                              _otpControllers.every(
                                (controller) => controller.text.isNotEmpty,
                              )) {
                            _verifyOtp();
                          }
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Countdown timer
                Text(
                  'Code expires in: $_formattedCountdown',
                  style: TextStyle(
                    color:
                        _remainingSeconds < 30
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 32),

                BlocBuilder<AuthBloc<T>, AuthState<T>>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoadingState;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthButton(
                          text: 'Verify Code',
                          onPressed: _verifyOtp,
                          isLoading: isLoading,
                          icon: Icons.check_circle_outline,
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the code? ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed:
                                  _remainingSeconds == 0 && !isLoading
                                      ? _resendOtp
                                      : null,
                              child: Text(
                                'Resend',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _remainingSeconds == 0 && !isLoading
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : Theme.of(context).disabledColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
