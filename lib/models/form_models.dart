import 'package:formz/formz.dart';
import 'package:validators/validators.dart';

import '../utils/utils.dart';

enum ValidationError {
  empty("This field is required."),
  invalid("Invalid entry."),
  invalidNewFirebasePassword("Password must contain at least 6 characters."),
  noMatchPassword("Password does not match."),
  outOfRange("Out of range.");

  final String errorMsg;

  const ValidationError(this.errorMsg);
}

/// Model for optional string form fields with unrestricted content. (Validator always validates.)
class StringFormField extends FormzInput<String, ValidationError> {
  const StringFormField.pure([super.value = '']) : super.pure();
  const StringFormField.dirty([super.value = '']) : super.dirty();

  @override
  ValidationError? validator(String value) => null;

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  @override
  String toString() => value;

  // use this to avoid getting an empty string as a valid value
  String? get valueOrNull => value.isNotEmpty ? value : null;
}

/// Model for required string form fields with unrestricted content.
class RequiredStringFormField extends StringFormField {
  const RequiredStringFormField.pure([super.value]) : super.pure();
  const RequiredStringFormField.dirty([super.value]) : super.dirty();

  @override
  ValidationError? validator(String value) {
    return value.isNotEmpty ? null : ValidationError.empty;
  }
}

/// Model for required new password confirmation field.
class RequiredConfirmPasswordFormField extends StringFormField {
  final String match;

  const RequiredConfirmPasswordFormField.pure([super.value, this.match = '']) : super.pure();
  const RequiredConfirmPasswordFormField.dirty({required this.match, String value = ''}) : super.dirty(value);

  @override
  ValidationError? validator(String value) {
    return value.trim() == match.trim() ? null : ValidationError.noMatchPassword;
  }
}

/// Model for required string form fields representing a new password for Appwrite.
class RequiredFirebaseNewPasswordFormField extends StringFormField {
  const RequiredFirebaseNewPasswordFormField.pure([super.value]) : super.pure();
  const RequiredFirebaseNewPasswordFormField.dirty([super.value]) : super.dirty();

  @override
  ValidationError? validator(String value) {
    final password = value.trim();

    if (password.isEmpty){
      return ValidationError.empty;
    }
    else if (password.length < 6) {
      return ValidationError.invalidNewFirebasePassword;
    }

    return null;
  }
}

/// Model for optional boolean form fields. (Validator always validates.)
class BoolFormField extends FormzInput<bool, ValidationError> {
  // ignore: avoid_positional_boolean_parameters
  const BoolFormField.pure([super.value = false]) : super.pure();
  // ignore: avoid_positional_boolean_parameters
  const BoolFormField.dirty([super.value = false]) : super.dirty();

  @override
  ValidationError? validator(bool? value) => null;
}

/// Model for required boolean form fields. (Validates only on true.)
class RequiredBoolFormField extends FormzInput<bool, ValidationError> {
  // ignore: avoid_positional_boolean_parameters
  const RequiredBoolFormField.pure([super.value = false]) : super.pure();
  // ignore: avoid_positional_boolean_parameters
  const RequiredBoolFormField.dirty([super.value = false]) : super.dirty();

  @override
  ValidationError? validator(bool? value) => value != null && value ? null : ValidationError.empty;
}

/// Model for email form fields.
class EmailFormField extends FormzInput<String, ValidationError> {
  const EmailFormField.pure([super.value = '']) : super.pure();
  const EmailFormField.dirty([super.value = '']) : super.dirty();

  @override
  ValidationError? validator(String value) {
    return value.isEmpty || isEmail(value) ? null : ValidationError.invalid;
  }

  // use this to avoid getting an empty string as a valid value
  String? get valueOrNull => value.isEmpty ? null : value;

  @override
  String toString() => value;
}

/// Model for required email form fields.
class RequiredEmailFormField extends EmailFormField {
  const RequiredEmailFormField.pure([super.value]) : super.pure();
  const RequiredEmailFormField.dirty([super.value]) : super.dirty();

  @override
  ValidationError? validator(String value) {
    if (value.isEmpty) {
      return ValidationError.empty;
    } else if (isEmail(value)) {
      return null;
    } else {
      return ValidationError.invalid;
    }
  }
}

/// Model for optional int form fields.
class IntFormField extends FormzInput<String, ValidationError> {
  const IntFormField.pure([super.value = '']) : super.pure();
  const IntFormField.dirty([super.value = '']) : super.dirty();

  @override
  ValidationError? validator(String value) {
    return value.isEmpty || intValue != null ? null : ValidationError.invalid;
  }

  int? get intValue => int.tryParse(value);
}

/// Model for required int form fields.
class RequiredIntFormField extends FormzInput<String, ValidationError> {
  const RequiredIntFormField.pure([super.value = '']) : super.pure();
  const RequiredIntFormField.dirty([super.value = '']) : super.dirty();

  @override
  ValidationError? validator(String value) {
    return value.isEmpty || intValue == null ? ValidationError.invalid : null;
  }

  int? get intValue => int.tryParse(value);
}

/// Model for optional fully qualified domain name form fields.
class DomainFormField extends FormzInput<String, ValidationError> {
  const DomainFormField.pure([super.value = '']) : super.pure();
  const DomainFormField.dirty([super.value = '']) : super.dirty();

  @override
  ValidationError? validator(String value) {
    return value.isEmpty || isFQDN(value, allowUnderscores: true) ? null : ValidationError.invalid;
  }

  // use this to avoid getting an empty string as a valid value
  String? get valueOrNull => value.isNotEmpty ? value : null;
}

/// Model for required fully qualified domain name or IP form fields.
class RequiredDomainOrIpFormField extends FormzInput<String, ValidationError> {
  const RequiredDomainOrIpFormField.pure([super.value = '']) : super.pure();
  const RequiredDomainOrIpFormField.dirty([super.value = '']) : super.dirty();

  @override
  ValidationError? validator(String value) {
    return value.isNotEmpty && (isFQDN(value, allowUnderscores: true) || isIP(value)) ? null : ValidationError.invalid;
  }

  // use this to avoid getting an empty string as a valid value
  String? get valueOrNull => value.isNotEmpty ? value : null;

  @override
  String toString() => value;
}

/// Model for optional URL form fields.
class URLFormField extends FormzInput<String, ValidationError> {
  const URLFormField.pure([super.value = '']) : super.pure();
  const URLFormField.dirty([super.value = '']) : super.dirty();

  @override
  ValidationError? validator(String value) {
    return value.isEmpty || isURL(value, allowUnderscore: true, requireProtocol: true, protocols: const ['http', 'https']) ? null : ValidationError.invalid;
  }

  // use this to avoid getting an empty string as a valid value
  String? get valueOrNull => value.isNotEmpty ? value : null;
}

/// Model for optional U.S. zip code form fields.
class ZipCodeFormField extends FormzInput<String, ValidationError> {
  const ZipCodeFormField.pure([super.value = '']) : super.pure();
  const ZipCodeFormField.dirty([super.value = '']) : super.dirty();

  @override
  ValidationError? validator(String value) {
    if (value.isNotEmpty && !isPostalCode(value, "US")) {
      return ValidationError.invalid;
    }

    return null;
  }

  // use this to avoid getting an empty string as a valid value
  String? get valueOrNull => value.isNotEmpty ? value : null;

  @override
  String toString() => value;
}

/// Model for required U.S. zip code form fields.
class RequiredZipCodeFormField extends ZipCodeFormField {
  const RequiredZipCodeFormField.pure([super.value]) : super.pure();
  const RequiredZipCodeFormField.dirty([super.value]) : super.dirty();

  @override
  ValidationError? validator(String value) {
    if (value.isEmpty) {
      return ValidationError.empty;
    } else if (isPostalCode(value, "US")) {
      return null;
    } else {
      return ValidationError.invalid;
    }
  }
}

/// Model for optional U.S. phone number form fields.
class PhoneFormField extends FormzInput<String, ValidationError> {
  const PhoneFormField.pure([super.value = '']) : super.pure();
  const PhoneFormField.dirty([super.value = '']) : super.dirty();

  @override
  ValidationError? validator(String value) {
    // US phone numbers should be 10 digits
    if (value.isNotEmpty && value.toDigitsOnly().length != 10) {
      return ValidationError.invalid;
    }

    return null;
  }

  // use this to avoid getting an empty string as a valid value
  String? get valueOrNull => value.isNotEmpty ? value : null;

  @override
  String toString() => value;
}

/// Model for required U.S. phone number form fields.
class RequiredPhoneFormField extends PhoneFormField {
  const RequiredPhoneFormField.pure([super.value]) : super.pure();
  const RequiredPhoneFormField.dirty([super.value]) : super.dirty();

  @override
  ValidationError? validator(String value) {
    // US phone numbers should be 10 digits
    if (value.isEmpty) {
      return ValidationError.empty;
    } else if (value.toDigitsOnly().length != 10) {
      return ValidationError.invalid;
    }

    return null;
  }
}

class IntRange {
  final int? min;
  final int? max;

  const IntRange({this.min, this.max});

  IntRange copyWith({int? min, int? max}) {
    return IntRange(
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }

  bool isInRange(int value) {
    bool inRange = true;

    if (min != null) {
      inRange = inRange && value >= min!;
    }

    if (max != null) {
      inRange = inRange && value <= max!;
    }

    return inRange;
  }

  @override
  String toString() => "$min${max != null ? '-$max' : '+'}";

  bool get isEmpty => min == null && max == null;
  bool get isNotEmpty => !isEmpty;
}

class IntRangeFormField extends FormzInput<IntRange, ValidationError> {
  const IntRangeFormField.pure([super.value = const IntRange()]) : super.pure();
  const IntRangeFormField.dirty(super.value) : super.dirty();

  @override
  ValidationError? validator(IntRange value) => null;

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

/// Model for required date form fields.
class RequiredDateFormField extends FormzInput<DateTime?, ValidationError> {
  const RequiredDateFormField.pure([super.value]) : super.pure();
  const RequiredDateFormField.dirty([super.value]) : super.dirty();

  @override
  ValidationError? validator(DateTime? value) {
    return value != null ? null : ValidationError.invalid;
  }

  bool get hasValue => value != null;

  @override
  String toString() => value.toString();
}

/// Model for required enum form fields.
class RequiredEnumFormField<T extends Enum> extends FormzInput<T?, ValidationError> {
  // ignore: avoid_positional_boolean_parameters
  const RequiredEnumFormField.pure([super.value]) : super.pure();
  // ignore: avoid_positional_boolean_parameters
  const RequiredEnumFormField.dirty([super.value]) : super.dirty();

  @override
  ValidationError? validator(T? value) => value != null ? null : ValidationError.empty;
}

/// Model for list form fields with custom validation.
class ListFormField<T> extends FormzInput<List<T>, ValidationError> {
  const ListFormField.pure([super.value = const []]) : super.pure();
  const ListFormField.dirty([super.value = const []]) : super.dirty();

  @override
  ValidationError? validator(List<T> value) => null;

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
}

/// Model for required list form fields (must have at least one item).
class RequiredListFormField<T> extends FormzInput<List<T>, ValidationError> {
  final int minLength;

  const RequiredListFormField.pure([this.minLength = 1]) : super.pure(const []);
  const RequiredListFormField.dirty(super.value, [this.minLength = 1]) : super.dirty();

  @override
  ValidationError? validator(List<T> value) {
    return value.length >= minLength ? null : ValidationError.empty;
  }

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
}
