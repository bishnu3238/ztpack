// lib/features/auth/presentation/widgets/resend_otp_timer.dart
import 'dart:async';
import 'package:flutter/material.dart';

class ResendOTPTimer extends StatefulWidget {
  final VoidCallback onResend;
  final int durationInSeconds;
  final bool isResendActive;
  final DateTime? lastResendTime;
  final Color activeColor;
  final Color inactiveColor;

  const ResendOTPTimer({
    super.key,
    required this.onResend,
    this.durationInSeconds = 60,
    this.isResendActive = true,
    this.lastResendTime,
    this.activeColor = Colors.deepPurple,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<ResendOTPTimer> createState() => _ResendOTPTimerState();
}

class _ResendOTPTimerState extends State<ResendOTPTimer> {
  late Timer _timer;
  late int _secondsRemaining;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationInSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer.cancel();
        }
      });
    });
  }

  void _handleResend() {
    widget.onResend();
    setState(() {
      _canResend = false;
      _secondsRemaining = widget.durationInSeconds;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return TextButton(
      onPressed: _canResend ? _handleResend : null,
      child: Text(
        _canResend
            ? 'Resend OTP'
            : 'Resend OTP in ${_formatTime(_secondsRemaining)}',
        style: TextStyle(
          color: _canResend ? theme.primary : Colors.grey,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}