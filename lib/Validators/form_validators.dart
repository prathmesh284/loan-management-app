/// Form Validators Utility
/// Centralized validation logic for all form fields in the application
/// Ensures consistency between frontend and backend validation

class FormValidators {
  // ==================== PHONE VALIDATION ====================
  /// Validates Indian phone number (10 digits, starts with 6-9)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }
    if (value.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Phone number must start with 6-9 and contain only digits';
    }
    return null;
  }

  // ==================== EMAIL VALIDATION ====================
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // ==================== AADHAR VALIDATION ====================
  /// Validates Aadhar number (12 digits only)
  static String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhar number cannot be empty';
    }
    if (value.length != 12) {
      return 'Aadhar number must be exactly 12 digits';
    }
    if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
      return 'Aadhar must contain only digits';
    }
    return null;
  }

  // ==================== PAN VALIDATION ====================
  /// Validates PAN number format (AAAAA0000A)
  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN number cannot be empty';
    }
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) {
      return 'PAN format must be: 5 letters + 4 digits + 1 letter (e.g., AAAAA0000A)';
    }
    return null;
  }

  // ==================== NAME VALIDATION ====================
  /// Validates customer/user name (3-100 characters, letters and spaces only)
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Name cannot exceed 100 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  // ==================== ADDRESS VALIDATION ====================
  /// Validates address (10-255 characters)
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address cannot be empty';
    }
    if (value.length < 10) {
      return 'Address must be at least 10 characters';
    }
    if (value.length > 255) {
      return 'Address cannot exceed 255 characters';
    }
    return null;
  }

  // ==================== AMOUNT VALIDATION ====================
  /// Validates loan/EMI amount (minimum 1000)
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount cannot be empty';
    }
    try {
      double amount = double.parse(value);
      if (amount < 1000) {
        return 'Amount must be at least 1000';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid amount';
    }
  }

  // ==================== WEIGHT VALIDATION ====================
  /// Validates gold weight (0.1 to 1000 grams)
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight cannot be empty';
    }
    try {
      double weight = double.parse(value);
      if (weight < 0.1) {
        return 'Weight must be at least 0.1 grams';
      }
      if (weight > 1000) {
        return 'Weight cannot exceed 1000 grams';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid weight';
    }
  }

  // ==================== GOLD PRICE VALIDATION ====================
  /// Validates gold price per gram (minimum 1 rupee)
  static String? validateGoldPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gold price cannot be empty';
    }
    try {
      double price = double.parse(value);
      if (price < 1) {
        return 'Gold price must be at least 1 rupee per gram';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid price';
    }
  }

  // ==================== LTV VALIDATION ====================
  /// Validates LTV (Loan-to-Value) - 0-100 percentage
  static String? validateLTV(String? value) {
    if (value == null || value.isEmpty) {
      return 'LTV cannot be empty';
    }
    try {
      double ltv = double.parse(value);
      if (ltv < 1) {
        return 'LTV must be at least 1%';
      }
      if (ltv > 100) {
        return 'LTV cannot exceed 100%';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid LTV percentage';
    }
  }

  // ==================== INTEREST RATE VALIDATION ====================
  /// Validates interest rate (0-100 percentage)
  static String? validateInterestRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Interest rate cannot be empty';
    }
    try {
      double rate = double.parse(value);
      if (rate < 0) {
        return 'Interest rate cannot be negative';
      }
      if (rate > 100) {
        return 'Interest rate cannot exceed 100%';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid interest rate';
    }
  }

  // ==================== TENURE VALIDATION ====================
  /// Validates tenure/period (1-84 months)
  static String? validateTenure(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tenure cannot be empty';
    }
    try {
      int tenure = int.parse(value);
      if (tenure < 1) {
        return 'Tenure must be at least 1 month';
      }
      if (tenure > 84) {
        return 'Tenure cannot exceed 84 months (7 years)';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid tenure';
    }
  }

  // ==================== PASSWORD VALIDATION ====================
  /// Validates password (minimum 8 characters)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // ==================== USERNAME VALIDATION ====================
  /// Validates username (4-50 characters, alphanumeric and underscore)
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }
    if (value.length < 4) {
      return 'Username must be at least 4 characters';
    }
    if (value.length > 50) {
      return 'Username cannot exceed 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  // ==================== GENERIC REQUIRED FIELD VALIDATION ====================
  /// Validates that a field is not empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  // ==================== GENERIC LENGTH VALIDATION ====================
  /// Validates field length
  static String? validateLength(String? value, int minLength, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }
    return null;
  }

  // ==================== MULTIPLE FIELD VALIDATION ====================
  /// Validates multiple required fields at once
  static Map<String, String> validateMultipleFields(Map<String, String?> fields) {
    Map<String, String> errors = {};
    
    fields.forEach((fieldName, value) {
      if (value == null || value.isEmpty) {
        errors[fieldName] = '$fieldName is required';
      }
    });
    
    return errors;
  }

  // ==================== DROPDOWN VALIDATION ====================
  /// Validates dropdown selection (not null or empty)
  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please select a $fieldName';
    }
    return null;
  }

  // ==================== BOOLEAN VALIDATION ====================
  /// Validates checkbox/boolean field
  static String? validateCheckbox(bool? value, String fieldName) {
    if (value == null || !value) {
      return 'Please accept $fieldName';
    }
    return null;
  }
}
