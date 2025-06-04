class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Username validation
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 50) {
      return 'Username must not exceed 50 characters';
    }

    final usernameRegex = RegExp(r'^[A-Za-z0-9_.@-]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username contains invalid characters';
    }

    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  // Strong password validation
  static String? strongPassword(String? value) {
    final basicValidation = password(value);
    if (basicValidation != null) return basicValidation;

    if (!RegExp(r'[A-Z]').hasMatch(value!)) {
      return 'Password must contain uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain number';
    }

    return null;
  }

  // Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Number validation
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Number'} is required';
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  // Positive number validation
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numberValidation = number(value, fieldName: fieldName);
    if (numberValidation != null) return numberValidation;

    final num = double.parse(value!);
    if (num <= 0) {
      return '${fieldName ?? 'Number'} must be positive';
    }

    return null;
  }

  // Asset number validation
  static String? assetNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Asset number is required';
    }

    if (value.length > 100) {
      return 'Asset number must not exceed 100 characters';
    }

    final assetRegex = RegExp(r'^[A-Za-z0-9_-]+$');
    if (!assetRegex.hasMatch(value)) {
      return 'Asset number must contain only alphanumeric characters, hyphens, and underscores';
    }

    return null;
  }

  // Code validation (plant_code, location_code, unit_code)
  static String? code(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Code'} is required';
    }

    if (value.length > 50) {
      return '${fieldName ?? 'Code'} must not exceed 50 characters';
    }

    final codeRegex = RegExp(r'^[A-Za-z0-9_-]+$');
    if (!codeRegex.hasMatch(value)) {
      return '${fieldName ?? 'Code'} must contain only alphanumeric characters, hyphens, and underscores';
    }

    return null;
  }

  // Description validation
  static String? description(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    if (value.length > 255) {
      return 'Description must not exceed 255 characters';
    }

    return null;
  }

  // Length validation
  static String? length(String? value, int min, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }

    if (value.length > max) {
      return '${fieldName ?? 'This field'} must not exceed $max characters';
    }

    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Search term validation
  static String? searchTerm(String? value) {
    if (value != null && value.length > 100) {
      return 'Search term must not exceed 100 characters';
    }
    return null;
  }
}

// Validation result class
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});

  factory ValidationResult.valid() {
    return ValidationResult(isValid: true, errors: []);
  }

  factory ValidationResult.invalid(List<String> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }
}
