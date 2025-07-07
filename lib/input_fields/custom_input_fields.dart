// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'input_validator.dart';

// /// Enum to specify the type of input field
// enum InputFieldType {
//   name,
//   phone,
//   email,
//   password,
//   text,
// }

// /// Abstract base class for custom input fields
// abstract class BaseInputField extends StatefulWidget {
//   const BaseInputField({
//     Key? key,
//     required this.label,
//     required this.hint,
//     this.controller,
//     this.onChanged,
//     this.initialValue,
//     this.validator,
//     this.errorText,
//     this.focusNode,
//     this.nextFocusNode,
//     this.keyboardType,
//     this.textInputAction,
//     this.isEnabled = true,
//     this.inputFormatters,
//     this.prefix,
//     this.suffix,
//     this.maxLength,
//     this.maxLines = 1,
//     this.minLines,
//     this.autofocus = false,
//   }) : super(key: key);

//   final String label;
//   final String hint;
//   final TextEditingController? controller;
//   final ValueChanged<String>? onChanged;
//   final String? initialValue;
//   final FormFieldValidator<String>? validator;
//   final String? errorText;
//   final FocusNode? focusNode;
//   final FocusNode? nextFocusNode;
//   final TextInputType? keyboardType;
//   final TextInputAction? textInputAction;
//   final bool isEnabled;
//   final List<TextInputFormatter>? inputFormatters;
//   final Widget? prefix;
//   final Widget? suffix;
//   final int? maxLength;
//   final int maxLines;
//   final int? minLines;
//   final bool autofocus;

//   /// Get the appropriate validator for the input field type
//   FormFieldValidator<String>? getValidator();

//   /// Create widget based on type
//   Widget build(BuildContext context);
// }

// /// A highly customizable text input field widget that supports different types of inputs
// /// with built-in validation based on the input type.
// class CustomInputField extends BaseInputField {
//   CustomInputField({
//     Key? key,
//     required String label,
//     required String hint,
//     required this.type,
//     TextEditingController? controller,
//     ValueChanged<String>? onChanged,
//     String? initialValue,
//     FormFieldValidator<String>? validator,
//     String? errorText,
//     FocusNode? focusNode,
//     FocusNode? nextFocusNode,
//     TextInputType? keyboardType,
//     TextInputAction? textInputAction = TextInputAction.next,
//     bool isEnabled = true,
//     List<TextInputFormatter>? inputFormatters,
//     Widget? prefix,
//     Widget? suffix,
//     int? maxLength,
//     int maxLines = 1,
//     int? minLines,
//     bool autofocus = false,
//     this.obscureText = false,
//     this.showTogglePassword = false,
//     this.textCapitalization = TextCapitalization.none,
//     this.fillColor,
//     this.borderRadius = 8.0,
//     this.borderColor,
//     this.errorBorderColor = Colors.red,
//     this.textStyle,
//     this.labelStyle,
//     this.hintStyle,
//     this.errorStyle,
//     this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//   }) : super(
//           key: key,
//           label: label,
//           hint: hint,
//           controller: controller,
//           onChanged: onChanged,
//           initialValue: initialValue,
//           validator: validator,
//           errorText: errorText,
//           focusNode: focusNode,
//           nextFocusNode: nextFocusNode,
//           keyboardType: keyboardType ?? _getKeyboardType(type),
//           textInputAction: textInputAction,
//           isEnabled: isEnabled,
//           inputFormatters: inputFormatters ?? _getInputFormatters(type),
//           prefix: prefix,
//           suffix: suffix,
//           maxLength: maxLength,
//           maxLines: type == InputFieldType.password ? 1 : maxLines,
//           minLines: minLines,
//           autofocus: autofocus,
//         );

//   final InputFieldType type;
//   final bool obscureText;
//   final bool showTogglePassword;
//   final TextCapitalization textCapitalization;
//   final Color? fillColor;
//   final double borderRadius;
//   final Color? borderColor;
//   final Color errorBorderColor;
//   final TextStyle? textStyle;
//   final TextStyle? labelStyle;
//   final TextStyle? hintStyle;
//   final TextStyle? errorStyle;
//   final EdgeInsetsGeometry contentPadding;

//   static TextInputType _getKeyboardType(InputFieldType type) {
//     switch (type) {
//       case InputFieldType.email:
//         return TextInputType.emailAddress;
//       case InputFieldType.phone:
//         return TextInputType.phone;
//       case InputFieldType.password:
//         return TextInputType.visiblePassword;
//       case InputFieldType.name:
//         return TextInputType.name;
//       case InputFieldType.text:
//       default:
//         return TextInputType.text;
//     }
//   }

//   static List<TextInputFormatter>? _getInputFormatters(InputFieldType type) {
//     switch (type) {
//       case InputFieldType.phone:
//         return [FilteringTextInputFormatter.digitsOnly];
//       default:
//         return null;
//     }
//   }

//   @override
//   FormFieldValidator<String>? getValidator() {
//     if (validator != null) return validator;
    
//     switch (type) {
//       case InputFieldType.name:
//         return InputValidator.validateName;
//       case InputFieldType.phone:
//         return InputValidator.validatePhone;
//       case InputFieldType.email:
//         return InputValidator.validateEmail;
//       case InputFieldType.password:
//         return InputValidator.validatePassword;
//       case InputFieldType.text:
//       default:
//         return (value) => value != null && value.isEmpty ? 'This field is required' : null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _CustomInputFieldState();
//   }

//   @override
//   State<CustomInputField> createState() => _CustomInputFieldState();
// }

// class _CustomInputFieldState extends State<CustomInputField> {
//   late TextEditingController _controller;
//   late bool _obscureText;
//   String? _errorText;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
//     _obscureText = widget.obscureText && widget.type == InputFieldType.password;
//   }

//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       _controller.dispose();
//     }
//     super.dispose();
//   }

//   InputDecoration _getInputDecoration() {
//     return InputDecoration(
//       labelText: widget.label,
//       hintText: widget.hint,
//       filled: widget.fillColor != null,
//       fillColor: widget.fillColor,
//       errorText: widget.errorText ?? _errorText,
//       prefixIcon: widget.prefix,
//       suffixIcon: widget.type == InputFieldType.password && widget.showTogglePassword
//           ? IconButton(
//               icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
//               onPressed: () {
//                 setState(() {
//                   _obscureText = !_obscureText;
//                 });
//               },
//             )
//           : widget.suffix,
//       contentPadding: widget.contentPadding,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         borderSide: BorderSide(
//           color: widget.borderColor ?? Theme.of(context).dividerColor,
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         borderSide: BorderSide(
//           color: widget.borderColor ?? Theme.of(context).dividerColor,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         borderSide: BorderSide(
//           color: widget.borderColor ?? Theme.of(context).primaryColor,
//           width: 2.0,
//         ),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         borderSide: BorderSide(
//           color: widget.errorBorderColor,
//         ),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         borderSide: BorderSide(
//           color: widget.errorBorderColor,
//           width: 2.0,
//         ),
//       ),
//       labelStyle: widget.labelStyle,
//       hintStyle: widget.hintStyle,
//       errorStyle: widget.errorStyle,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: _controller,
//       focusNode: widget.focusNode,
//       keyboardType: widget.keyboardType,
//       textInputAction: widget.textInputAction,
//       textCapitalization: widget.textCapitalization,
//       obscureText: _obscureText,
//       maxLength: widget.maxLength,
//       maxLines: widget.maxLines,
//       minLines: widget.minLines,
//       enabled: widget.isEnabled,
//       autofocus: widget.autofocus,
//       style: widget.textStyle,
//       inputFormatters: widget.inputFormatters,
//       decoration: _getInputDecoration(),
//       validator: (value) {
//         final validator = widget.getValidator();
//         if (validator != null) {
//           final error = validator(value);
//           if (mounted) {
//             setState(() {
//               _errorText = error;
//             });
//           }
//           return error;
//         }
//         return null;
//       },
//       onChanged: (value) {
//         if (widget.onChanged != null) {
//           widget.onChanged!(value);
//         }
        
//         // Optional: validate on change
//         // final validator = widget.getValidator();
//         // if (validator != null) {
//         //   setState(() {
//         //     _errorText = validator(value);
//         //   });
//         // }
//       },
//       onFieldSubmitted: (_) {
//         if (widget.nextFocusNode != null) {
//           FocusScope.of(context).requestFocus(widget.nextFocusNode);
//         }
//       },
//     );
//   }
// }