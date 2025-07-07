// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart'; // Make sure to add pinput dependency to pubspec.yaml
// import 'input_validator.dart';

// /// A custom OTP input field using the pinput package for a polished, pre-built solution.
// class CustomOTPField extends StatefulWidget {
//   const CustomOTPField({
//     Key? key,
//     this.length = 6,
//     this.onCompleted,
//     this.onChanged,
//     this.validator,
//     this.errorText,
//     this.focusNode,
//     this.controller,
//     this.autofocus = false,
//     this.enabled = true,
//     this.defaultPinTheme,
//     this.focusedPinTheme,
//     this.submittedPinTheme,
//     this.errorPinTheme,
//     this.disabledPinTheme,
//     this.spaceBetween = 8,
//     this.cursor,
//     this.animationDuration = const Duration(milliseconds: 150),
//     this.animationType = PinAnimationType.scale,
//     this.hapticFeedbackType = HapticFeedbackType.lightImpact,
//     this.showCursor = true,
//   }) : super(key: key);

//   final int length;
//   final Function(String)? onCompleted;
//   final Function(String)? onChanged;
//   final FormFieldValidator<String>? validator;
//   final String? errorText;
//   final FocusNode? focusNode;
//   final TextEditingController? controller;
//   final bool autofocus;
//   final bool enabled;
//   final PinTheme? defaultPinTheme;
//   final PinTheme? focusedPinTheme;
//   final PinTheme? submittedPinTheme;
//   final PinTheme? errorPinTheme;
//   final PinTheme? disabledPinTheme;
//   final double spaceBetween;
//   final Cursor? cursor;
//   final Duration animationDuration;
//   final PinAnimationType animationType;
//   final HapticFeedbackType hapticFeedbackType;
//   final bool showCursor;

//   @override
//   State<CustomOTPField> createState() => _CustomOTPFieldState();
// }

// class _CustomOTPFieldState extends State<CustomOTPField> {
//   late TextEditingController _controller;
//   String? _errorText;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? TextEditingController();
//   }

//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       _controller.dispose();
//     }
//     super.dispose();
//   }

//   FormFieldValidator<String>? _getValidator() {
//     if (widget.validator != null) return widget.validator;
//     return (value) => InputValidator.validateOTP(
//           value,
//           length: widget.length,
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Default pin theme
//     final defaultPinTheme = widget.defaultPinTheme ??
//         PinTheme(
//           width: 56,
//           height: 56,
//           textStyle: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(8),
//           ),
//         );

//     // Focused pin theme
//     final focusedPinTheme = widget.focusedPinTheme ??
//         defaultPinTheme.copyDecorationWith(
//           border: Border.all(color: Theme.of(context).primaryColor, width: 2),
//         );

//     // Submitted pin theme
//     final submittedPinTheme = widget.submittedPinTheme ??
//         defaultPinTheme.copyDecorationWith(
//           border: Border.all(color: Theme.of(context).primaryColor),
//         );

//     // Error pin theme
//     final errorPinTheme = widget.errorPinTheme ??
//         defaultPinTheme.copyDecorationWith(
//           border: Border.all(color: Colors.red),
//         );

//     // Disabled pin theme
//     final disabledPinTheme = widget.disabledPinTheme ??
//         defaultPinTheme.copyDecorationWith(
//           border: Border.all(color: Colors.grey.shade300),
//         );

//     return FormField<String>(
//       initialValue: _controller.text,
//       validator: _getValidator(),
//       builder: (FormFieldState<String> field) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Pinput(
//               length: widget.length,
//               controller: _controller,
//               focusNode: widget.focusNode,
//               defaultPinTheme: defaultPinTheme,
//               focusedPinTheme: focusedPinTheme,
//               submittedPinTheme: submittedPinTheme,
//               errorPinTheme: errorPinTheme,
//               disabledPinTheme: disabledPinTheme,
//               errorText: widget.errorText ?? _errorText,
//               pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
//               showCursor: widget.showCursor,
//               cursor: widget.cursor,
//               enabled: widget.enabled,
//               autofocus: widget.autofocus,
//               hapticFeedbackType: widget.hapticFeedbackType,
//               animationDuration: widget.animationDuration,
//               animationType: widget.animationType,
//               pinAnimationType: widget.animationType,
//               separator: SizedBox(width: widget.spaceBetween),
//               forceErrorState: field.hasError,
//               validator: (value) {
//                 final validator = _getValidator();
//                 if (validator != null) {
//                   final error = validator(value);
//                   if (mounted) {
//                     setState(() {
//                       _errorText = error;
//                     });
//                   }
//                   return error;
//                 }
//                 return null;
//               },
//               onCompleted: widget.onCompleted,
//               onChanged: (value) {
//                 field.didChange(value);
//                 if (widget.onChanged != null) {
//                   widget.onChanged!(value);
//                 }
//               },
//             ),
//             if (field.hasError)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0, left: 8.0),
//                 child: Text(
//                   field.errorText ?? '',
//                   style: TextStyle(
//                     color: Colors.red.shade700,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }