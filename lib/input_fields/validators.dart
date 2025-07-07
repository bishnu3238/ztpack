class Validators {
  // Main validation method that can make validation optional
  static String? validate({
    required String? value,
    required ValidationType type,
    bool isRequired = true,
    String fieldName = 'field',
  }) {
    // Check if value is required
    if ((value == null || value.isEmpty) && isRequired) {
      return 'Please enter $fieldName';
    } else if ((value == null || value.isEmpty) && !isRequired) {
      // Skip validation for optional empty fields
      return null;
    }

    // Proceed with type-specific validation
    switch (type) {
      case ValidationType.email:
        return _validateEmail(value);
      case ValidationType.password:
        return _validatePassword(value);
      case ValidationType.mobile:
        return _validateMobile(value);
      case ValidationType.panCard:
        return _validatePanCard(value);
      case ValidationType.aadhaarCard:
        return _validateAadhaarCard(value);
      case ValidationType.gst:
        return _validateGST(value);
      case ValidationType.bikeNumber:
        return _validateBikeNumber(value);
      case ValidationType.carNumber:
        return _validateCarNumber(value);
      case ValidationType.username:
        return _validateUsername(value);
      case ValidationType.name:
        return _validateName(value);
      case ValidationType.address:
        return _validateAddress(value);
      case ValidationType.pincode:
        return _validatePincode(value);
      case ValidationType.ifscCode:
        return _validateIFSC(value);
      case ValidationType.accountNumber:
        return _validateAccountNumber(value);
      case ValidationType.url:
        return _validateURL(value);
      case ValidationType.date:
        return _validateDate(value);
      case ValidationType.required:
        return null; // Already validated above
    }
  }

  // Private validation methods
  static String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? _validatePassword(String? value) {
    if (value!.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*?[a-z])').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'(?=.*?[!@#$%^&*(),.?":{}|<>])').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? _validateMobile(String? value) {
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value!)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? _validatePanCard(String? value) {
    // PAN format: AAAAA1234A (5 letters, 4 numbers, 1 letter)
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value!)) {
      return 'Please enter a valid PAN card number (e.g., AAAAA1234A)';
    }
    return null;
  }

  static String? _validateAadhaarCard(String? value) {
    // Remove spaces if any
    final aadhaarNumber = value!.replaceAll(' ', '');

    // Check if it's 12 digits
    if (!RegExp(r'^[0-9]{12}$').hasMatch(aadhaarNumber)) {
      return 'Please enter a valid 12-digit Aadhaar number';
    }

    // Optionally implement Verhoeff algorithm for Aadhaar validation
    return null;
  }

  static String? _validateGST(String? value) {
    // GST format: 22AAAAA0000A1Z5
    final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!gstRegex.hasMatch(value!)) {
      return 'Please enter a valid GST number (e.g., 22AAAAA0000A1Z5)';
    }
    return null;
  }

  static String? _validateBikeNumber(String? value) {
    // Format: MH12AB1234 or MH-12-AB-1234
    final bikeRegex = RegExp(r'^[A-Z]{2}[-\s]?[0-9]{1,2}[-\s]?[A-Z]{1,2}[-\s]?[0-9]{1,4}$');
    if (!bikeRegex.hasMatch(value!)) {
      return 'Please enter a valid bike registration number (e.g., MH12AB1234)';
    }
    return null;
  }

  static String? _validateCarNumber(String? value) {
    // Same as bike number in India
    return _validateBikeNumber(value);
  }

  static String? _validateUsername(String? value) {
    if (value!.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (value.length > 30) {
      return 'Username cannot exceed 30 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and ._-';
    }
    return null;
  }

  static String? _validateName(String? value) {
    if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(value!)) {
      return 'Please enter a valid name (letters, spaces, and dots only)';
    }
    return null;
  }

  static String? _validateAddress(String? value) {
    if (value!.length < 5) {
      return 'Address must be at least 5 characters long';
    }
    return null;
  }

  static String? _validatePincode(String? value) {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value!)) {
      return 'Please enter a valid 6-digit pincode';
    }
    return null;
  }

  static String? _validateIFSC(String? value) {
    // IFSC format: SBIN0000123 (4 chars bank code + 0 + 6 digits branch code)
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (!ifscRegex.hasMatch(value!)) {
      return 'Please enter a valid IFSC code (e.g., SBIN0000123)';
    }
    return null;
  }

  static String? _validateAccountNumber(String? value) {
    // Account numbers are usually 9-18 digits
    if (!RegExp(r'^[0-9]{9,18}$').hasMatch(value!)) {
      return 'Please enter a valid account number (9-18 digits)';
    }
    return null;
  }

  static String? _validateURL(String? value) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value!)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? _validateDate(String? value) {
    try {
      // Try parsing the date in format dd/mm/yyyy
      final parts = value!.split('/');
      if (parts.length != 3) {
        return 'Please enter a valid date in format dd/mm/yyyy';
      }

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900 || year > 2100) {
        return 'Please enter a valid date';
      }

      return null;
    } catch (e) {
      return 'Please enter a valid date in format dd/mm/yyyy';
    }
  }

  // Legacy methods for backward compatibility
  static String? validateEmail(String? value) {
    return validate(value: value, type: ValidationType.email, fieldName: 'email');
  }

  static String? validatePassword(String? value) {
    return validate(value: value, type: ValidationType.password, fieldName: 'password');
  }

  static String? validateRequired(String? value, String fieldName) {
    return validate(value: value, type: ValidationType.required, fieldName: fieldName);
  }

  static String? validateMobile(String? value) {
    return validate(value: value, type: ValidationType.mobile, fieldName: 'mobile number');
  }


  /// Validates a dropdown selection.
  /// Returns null if valid, otherwise returns an error message.
  static String? validateDropdown<T>(T? value, {
    String errorMessage = 'Please select an option',
  }) {
    if (value == null) {
      return errorMessage;
    }
    return null;
  }

  /// Validates an OTP input.
  /// Returns null if valid, otherwise returns an error message.
  static String? validateOTP(String? value, {
    String errorMessage = 'Please enter a valid code',
    int length = 6,
  }) {
    if (value == null || value.isEmpty) {
      return 'OTP code is required';
    }
    if (value.length != length) {
      return 'OTP code must be $length digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP code must contain only digits';
    }
    return null;
  }
}


// Enum to specify validation types
enum ValidationType {
  email,
  password,
  mobile,
  panCard,
  aadhaarCard,
  gst,
  bikeNumber,
  carNumber,
  username,
  name,
  address,
  pincode,
  ifscCode,
  accountNumber,
  url,
  date,
  required,
}