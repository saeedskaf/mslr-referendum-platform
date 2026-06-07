import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class FormValidators {
  final BuildContext context;

  FormValidators(this.context);

  // Email validator
  MultiValidator get emailValidator => MultiValidator([
    RequiredValidator(errorText: "Email is required"),
    EmailValidator(errorText: "Please enter a valid email address"),
  ]);

  // Password validator
  MultiValidator get passwordValidator => MultiValidator([
    RequiredValidator(errorText: "Password is required"),
    MinLengthValidator(8, errorText: "Password must be at least 8 characters"),
  ]);

  // Full name validator
  MultiValidator get fullNameValidator => MultiValidator([
    RequiredValidator(errorText: "Full name is required"),
    MinLengthValidator(2, errorText: "Name must be at least 2 characters"),
    MaxLengthValidator(100, errorText: "Name is too long"),
  ]);

  // Phone number validator
  MultiValidator get phoneValidator => MultiValidator([
    RequiredValidator(errorText: "Phone number is required"),
    MinLengthValidator(10, errorText: "Please enter a valid phone number"),
    PatternValidator(r'^\d+$', errorText: "Phone must contain only numbers"),
  ]);

  // SCC validator
  MultiValidator get sccValidator => MultiValidator([
    RequiredValidator(errorText: "SCC is required"),
    MinLengthValidator(10, errorText: "SCC must be exactly 10 characters"),
    MaxLengthValidator(10, errorText: "SCC must be exactly 10 characters"),
    PatternValidator(
      r'^[A-Z0-9]+$',
      errorText: "SCC must contain only letters and numbers",
    ),
  ]);

  // Date of birth validator (basic)
  MultiValidator get dateOfBirthValidator => MultiValidator([
    RequiredValidator(errorText: "Date of birth is required"),
  ]);

  // Referendum title validator (for admin)
  MultiValidator get referendumTitleValidator => MultiValidator([
    RequiredValidator(errorText: "Referendum title is required"),
    MinLengthValidator(10, errorText: "Title must be at least 10 characters"),
    MaxLengthValidator(200, errorText: "Title is too long (max 200)"),
  ]);

  // Referendum description validator (for admin)
  MultiValidator get referendumDescriptionValidator => MultiValidator([
    RequiredValidator(errorText: "Description is required"),
    MinLengthValidator(
      20,
      errorText: "Description must be at least 20 characters",
    ),
    MaxLengthValidator(1000, errorText: "Description is too long (max 1000)"),
  ]);

  // Referendum option validator (for admin)
  MultiValidator get referendumOptionValidator => MultiValidator([
    RequiredValidator(errorText: "Option text is required"),
    MinLengthValidator(3, errorText: "Option must be at least 3 characters"),
    MaxLengthValidator(200, errorText: "Option is too long (max 200)"),
  ]);

  // Age validator (18+ only)
  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return "Date of birth is required";
    }

    try {
      final dob = DateTime.parse(value);
      final today = DateTime.now();
      final age =
          today.year -
          dob.year -
          ((today.month > dob.month ||
                  (today.month == dob.month && today.day >= dob.day))
              ? 0
              : 1);

      if (age < 18) {
        return "You must be at least 18 years old to register";
      }

      if (dob.isAfter(today)) {
        return "Date of birth cannot be in the future";
      }

      return null;
    } catch (e) {
      return "Invalid date format";
    }
  }

  // Password match validator
  String? passwordMatchValidator(String password, String? value) {
    if (value != password) {
      return "Passwords do not match";
    }
    return null;
  }
}
