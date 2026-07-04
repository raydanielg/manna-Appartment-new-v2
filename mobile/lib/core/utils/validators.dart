class Validators {
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^255[0-9]{9}$').hasMatch(value)) return 'Enter a valid Tanzania phone number';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.isEmpty) return ' is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
    return null;
  }
}
