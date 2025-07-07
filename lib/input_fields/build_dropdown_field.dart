import 'package:flutter/material.dart';

/// A highly customizable and reusable dropdown form field with enhanced features
/// for Flutter applications.
class BuildDropdownField<T> extends StatefulWidget {
  /// The currently selected value
  final T? value;

  /// The list of items to display in the dropdown
  final List<T> items;

  /// Function called when the selected value changes
  final ValueChanged<T?>? onChanged;

  /// Function to convert each item to a display string
  final String Function(T)? itemLabelBuilder;

  /// Function to build a custom item widget
  final Widget Function(T)? itemBuilder;

  /// Placeholder text when no item is selected
  final String? hint;

  /// Whether this field is required
  final bool isRequired;

  /// Error message to display when validation fails
  final String? errorText;

  /// Whether the dropdown is enabled
  final bool enabled;

  /// Decoration for the dropdown container
  final BoxDecoration? decoration;

  /// Padding for the dropdown button
  final EdgeInsetsGeometry padding;

  /// Border radius for the dropdown
  final double borderRadius;

  /// Icon shown when dropdown is closed
  final Widget? icon;

  /// Custom validation function
  final String? Function(T?)? validator;

  /// Label for the form field
  final String? label;

  /// Style for dropdown items
  final TextStyle? itemStyle;

  /// Style for the selected value
  final TextStyle? selectedItemStyle;

  /// Style for the hint text
  final TextStyle? hintStyle;

  /// Max height of the dropdown menu
  final double? dropdownMaxHeight;

  /// Background color of the dropdown button
  final Color? backgroundColor;

  /// Whether to add a loading indicator when items are being fetched
  final bool isLoading;

  /// Whether the dropdown can have null value
  final bool allowNull;

  /// Whether to automatically dismiss dropdown on selection
  final bool autoDismiss;

  const BuildDropdownField({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.itemLabelBuilder,
    this.itemBuilder,
    this.hint,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
    this.decoration,
    this.padding = const EdgeInsets.symmetric(horizontal: 15),
    this.borderRadius = 8,
    this.icon,
    this.validator,
    this.label,
    this.itemStyle,
    this.selectedItemStyle,
    this.hintStyle,
    this.dropdownMaxHeight,
    this.backgroundColor,
    this.isLoading = false,
    this.allowNull = false,
    this.autoDismiss = true,
  });

  @override
  State<BuildDropdownField<T>> createState() => _BuildDropdownFieldState<T>();
}

class _BuildDropdownFieldState<T> extends State<BuildDropdownField<T>> {
  bool _isTouched = false;

  String _getItemLabel(T item) {
    if (widget.itemLabelBuilder != null) {
      return widget.itemLabelBuilder!(item);
    }
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Default decoration if not provided
    final BoxDecoration decoration = widget.decoration ??
        BoxDecoration(
          border: Border.all(
            color: widget.errorText != null && _isTouched
                ? Theme.of(context).colorScheme.error
                : Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: widget.backgroundColor ?? Colors.transparent,
        );

    // Handle case where current value is not in items list anymore
    final bool isValueValid = widget.value == null || widget.items.contains(widget.value);
    final T? safeValue = isValueValid ? widget.value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional label
        if (widget.label != null) ...[
          Text(
            "${widget.label}${widget.isRequired ? ' *' : ''}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
        ],

        // Dropdown field
        FormField<T>(
          initialValue: safeValue,
          validator: widget.validator,
          builder: (FormFieldState<T> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: decoration,
                  child: DropdownButtonHideUnderline(
                    child: widget.isLoading
                    // Show loading indicator when loading
                        ? _buildLoadingDropdown(context, field)
                    // Show normal dropdown when not loading
                        : _buildDropdown(context, field, safeValue),
                  ),
                ),

                // Error text
                if ((widget.errorText != null || field.hasError) && _isTouched) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.errorText ?? field.errorText ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // Loading state for the dropdown
  Widget _buildLoadingDropdown(BuildContext context, FormFieldState<T> field) {
    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.hint ?? 'Loading...',
              style: widget.hintStyle ?? const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  // Actual dropdown implementation
  Widget _buildDropdown(BuildContext context, FormFieldState<T> field, T? safeValue) {
    return DropdownButton<T>(
      value: safeValue,
      isExpanded: true,
      padding: widget.padding,
      hint: widget.hint != null
          ? Text(
        widget.hint!,
        style: widget.hintStyle ?? const TextStyle(color: Colors.grey),
      )
          : null,
      underline: const SizedBox.shrink(),
      icon: widget.icon ?? const Icon(Icons.arrow_drop_down),
      elevation: 16,
      isDense: true,
      onTap: () {
        setState(() {
          _isTouched = true;
        });
      },
      style: widget.selectedItemStyle,
      dropdownColor: Theme.of(context).cardColor,
      items: [
        // Add null option if allowed
        if (widget.allowNull)
          DropdownMenuItem<T>(
            value: null,
            child: Text(
              'None',
              style: widget.itemStyle,
            ),
          ),
        // Add regular items
        ...widget.items.map<DropdownMenuItem<T>>((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: widget.itemBuilder != null
                ? widget.itemBuilder!(item)
                : Text(
              _getItemLabel(item),
              style: widget.itemStyle,
            ),
          );
        }).toList(),
      ],
      onChanged: widget.enabled
          ? (T? newValue) {
        setState(() {
          _isTouched = true;
        });

        field.didChange(newValue);
        if (widget.onChanged != null) {
          widget.onChanged!(newValue);
        }

        // Auto-dismiss dialog if required (useful for modal sheets)
        if (widget.autoDismiss && newValue != null) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
      }
          : null,
    );
  }
}