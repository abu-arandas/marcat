mixin FormValidation {
  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your first name';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your last name';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? validateCode(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your code';
    if (value.length != 6) return 'must be 6 characters';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Include at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    // Optionally, you can validate the confirm password with the same criteria.
    return validatePassword(value);
  }
}
