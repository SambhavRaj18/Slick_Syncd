import '../constants/app_strings.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.emptyField;
    final regex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.emptyField;
    if (value.length < 8) return AppStrings.weakPassword;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return AppStrings.emptyField;
    if (value != original) return AppStrings.passwordMismatch;
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.emptyField;
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.emptyField;
    if (value.trim().length < 2) return 'Name must be at least 2 characters.';
    return null;
  }
}
