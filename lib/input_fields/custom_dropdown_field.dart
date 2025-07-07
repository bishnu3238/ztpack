import 'package:flutter/material.dart';
import 'validators.dart';

/// Abstract base class for custom dropdown fields
abstract class BaseDropdownField<T> extends StatefulWidget {
  const BaseDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.validator,
    this.errorText,
    this.isEnabled = true,
    this.isRequired = true,
  });

  final String label;
  final String hint;
  final List<T> items;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final String? errorText;
  final bool isEnabled;
  final bool isRequired;

  /// Get the appropriate validator for the dropdown field
  FormFieldValidator<T>? getValidator();

  /// Create dropdown widget
  Widget build(BuildContext context);
}

/// A highly customizable dropdown field widget that supports selection
/// from a list of items with built-in validation.
class CustomDropdownField<T> extends BaseDropdownField<T> {

  const CustomDropdownField({
    super.key,
    required super.label,
    required super.hint,
    required super.items,
    super.selectedValue,
    super.onChanged,
    super.validator,
    super.errorText,
    super.isEnabled,
    super.isRequired,
    this.itemBuilder,
    this.dropdownBuilder,
    this.fillColor,
    this.borderRadius = 8.0,
    this.borderColor,
    this.errorBorderColor = Colors.red,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.icon,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  /// Function to build dropdown menu items
  final Widget Function(BuildContext context, T item)? itemBuilder;

  /// Function to build the dropdown button
  final Widget Function(BuildContext context, T? selectedItem)? dropdownBuilder;

  final Color? fillColor;
  final double borderRadius;
  final Color? borderColor;
  final Color errorBorderColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final Widget? icon;
  final EdgeInsetsGeometry contentPadding;

  @override
  FormFieldValidator<T>? getValidator() {
    if (validator != null) return validator;
    if (isRequired) {
      return Validators.validateDropdown;
    }
    return null;
  }

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();

    @override
  Widget build(BuildContext context) {
    return _CustomDropdownFieldState<T>().build(context);
  }

}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  T? _selectedValue;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
  }

  @override
  void didUpdateWidget(CustomDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _selectedValue = widget.selectedValue;
    }
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      filled: widget.fillColor != null,
      fillColor: widget.fillColor,
      errorText: widget.errorText ?? _errorText,
      contentPadding: widget.contentPadding,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: widget.borderColor ?? Theme.of(context).dividerColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: widget.borderColor ?? Theme.of(context).dividerColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: widget.borderColor ?? Theme.of(context).primaryColor,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: widget.errorBorderColor,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: widget.errorBorderColor,
          width: 2.0,
        ),
      ),
      labelStyle: widget.labelStyle,
      hintStyle: widget.hintStyle,
      errorStyle: widget.errorStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: _selectedValue,
      validator: (value) {
        final validator = widget.getValidator();
        if (validator != null) {
          final error = validator(value);
          if (mounted) {
            setState(() {
              _errorText = error;
            });
          }
          return error;
        }
        return null;
      },
      builder: (FormFieldState<T> field) {
        return InputDecorator(
          decoration: _getInputDecoration(),
          isEmpty: _selectedValue == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: _selectedValue,
              isDense: true,
              isExpanded: true,
              icon: widget.icon ?? const Icon(Icons.arrow_drop_down),
              style: widget.textStyle,
              hint: Text(
                widget.hint,
                style: widget.hintStyle,
              ),
              onChanged: widget.isEnabled
                  ? (T? value) {
                      setState(() {
                        _selectedValue = value;
                        field.didChange(value);
                      });
                      if (widget.onChanged != null) {
                        widget.onChanged!(value);
                      }
                    }
                  : null,
              items: widget.items.map<DropdownMenuItem<T>>((T item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: widget.itemBuilder != null
                      ? widget.itemBuilder!(context, item)
                      : Text(item.toString()),
                );
              }).toList(),
              selectedItemBuilder: widget.dropdownBuilder != null
                  ? (BuildContext context) {
                      return widget.items.map<Widget>((T item) {
                        return widget.dropdownBuilder!(context, item);
                      }).toList();
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }
}