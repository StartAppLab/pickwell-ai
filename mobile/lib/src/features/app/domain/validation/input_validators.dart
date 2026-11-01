import 'package:injectable/injectable.dart';

import '../../../../core/types/_types.dart';

/// Input validation utilities for the app
/// Provides consistent validation across all features
@injectable
class InputValidators {
  const InputValidators();

  /// Validates post text for reply generation
  StringValidator get postTextValidator =>
      StringValidator().minLength(10).maxLength(2000).forAsciiOnly;

  /// Validates author handle (username)
  StringValidator get authorHandleValidator => StringValidator.create(
    validators: <StringValidatorCallback>[],
    isOptional: true,
  ).maxLength(50).forUsername;

  /// Validates URL format
  StringValidator get urlValidator => StringValidator.create(
    validators: <StringValidatorCallback>[],
    isOptional: true,
  ).maxLength(500).add(_isValidUrl);

  /// Validates user persona/bio text
  StringValidator get personaValidator => StringValidator.create(
    validators: <StringValidatorCallback>[],
    isOptional: true,
  ).maxLength(500).forAsciiOnly;

  /// Validates display name
  StringValidator get displayNameValidator => StringValidator.create(
    validators: <StringValidatorCallback>[],
    isOptional: true,
  ).maxLength(100).forLettersOnly;

  /// Validates user ID format
  StringValidator get userIdValidator => StringValidator().minLength(1).maxLength(100).forAsciiOnly;

  /// Validates email format
  StringValidator get emailValidator => StringValidator().forEmail;

  /// Validates password strength
  StringValidator get passwordValidator =>
      StringValidator().minLength(8).maxLength(128).forAsciiOnly;

  /// Validates first name
  StringValidator get firstNameValidator =>
      StringValidator().minLength(1).maxLength(50).forLettersOnly;

  /// Validates last name (optional)
  StringValidator get lastNameValidator => StringValidator.create(
    validators: <StringValidatorCallback>[],
    isOptional: true,
  ).maxLength(50).forLettersOnly;

  /// Validates tone values (0.0 to 1.0)
  StringValidator get toneValidator =>
      StringValidator().forDecimalNumbersOnly.add(_isValidToneValue);

  /// Validates niche tags
  StringValidator get nicheValidator => StringValidator.create(
    validators: <StringValidatorCallback>[],
    isOptional: true,
  ).maxLength(100).forAsciiOnly;

  /// Custom URL validation
  IsValid? _isValidUrl(String value) {
    if (value.isEmpty) return null; // Optional field
    final uri = Uri.tryParse(value);
    if (uri == null || (!uri.hasScheme || (!uri.scheme.startsWith('http')))) {
      return IsValid.string('Invalid URL format');
    }
    return null;
  }

  /// Custom tone value validation (0.0 to 1.0)
  IsValid? _isValidToneValue(String value) {
    final double? numValue = double.tryParse(value);
    if (numValue == null) return IsValid.string('Invalid number format');
    if (numValue < 0.0 || numValue > 1.0) {
      return IsValid.string('Tone value must be between 0.0 and 1.0');
    }
    return null;
  }

  /// Validates shared content entity
  ValidationResult validateSharedContent({
    required String text,
    String? url,
    String? authorHandle,
  }) {
    final errors = <String, String>{};

    // Validate post text
    final textValidation = postTextValidator.test(text);
    if (textValidation != null) {
      errors['text'] = _getValidationMessage(textValidation);
    }

    // Validate URL if provided
    if (url != null && url.isNotEmpty) {
      final urlValidation = urlValidator.test(url);
      if (urlValidation != null) {
        errors['url'] = _getValidationMessage(urlValidation);
      }
    }

    // Validate author handle if provided
    if (authorHandle != null && authorHandle.isNotEmpty) {
      final handleValidation = authorHandleValidator.test(authorHandle);
      if (handleValidation != null) {
        errors['authorHandle'] = _getValidationMessage(handleValidation);
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validates user profile data
  ValidationResult validateUserProfile({
    required String displayName,
    String? persona,
    required String toneFormality,
    required String toneHumor,
    required String toneDirectness,
  }) {
    final errors = <String, String>{};

    // Validate display name
    final nameValidation = displayNameValidator.test(displayName);
    if (nameValidation != null) {
      errors['displayName'] = _getValidationMessage(nameValidation);
    }

    // Validate persona if provided
    if (persona != null && persona.isNotEmpty) {
      final personaValidation = personaValidator.test(persona);
      if (personaValidation != null) {
        errors['persona'] = _getValidationMessage(personaValidation);
      }
    }

    // Validate tone values
    final formalityValidation = toneValidator.test(toneFormality);
    if (formalityValidation != null) {
      errors['toneFormality'] = _getValidationMessage(formalityValidation);
    }

    final humorValidation = toneValidator.test(toneHumor);
    if (humorValidation != null) {
      errors['toneHumor'] = _getValidationMessage(humorValidation);
    }

    final directnessValidation = toneValidator.test(toneDirectness);
    if (directnessValidation != null) {
      errors['toneDirectness'] = _getValidationMessage(directnessValidation);
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Converts validation errors to user-friendly messages
  String _getValidationMessage(IsValid validation) {
    switch (validation) {
      case IsValid.empty:
        return 'This field is required';
      case IsValid.tooShort:
        return 'Text is too short';
      case IsValid.tooLong:
        return 'Text is too long';
      case IsValid.containsWhitespace:
        return 'Cannot contain spaces';
      case IsValid.notEmail:
        return 'Please enter a valid email address';
      case IsValid.notUsername:
        return 'Please enter a valid username';
      case IsValid.notAsciiOnly:
        return 'Only standard characters are allowed';
      case IsValid.notLettersOnly:
        return 'Only letters are allowed';
      case IsValid.notNumbersOnly:
        return 'Only numbers are allowed';
      case IsValid.notDecimalNumbersOnly:
        return 'Only numbers and decimals are allowed';
      default:
        return 'Invalid input';
    }
  }
}

/// Result of validation containing success status and error messages
class ValidationResult {
  const ValidationResult({required this.isValid, required this.errors});

  final bool isValid;
  final Map<String, String> errors;

  /// Gets the first error message
  String? get firstError => errors.values.isNotEmpty ? errors.values.first : null;

  /// Gets all error messages as a list
  List<String> get allErrors => errors.values.toList();

  /// Gets error for a specific field
  String? getErrorForField(String field) => errors[field];
}
