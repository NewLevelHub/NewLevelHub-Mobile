import 'package:json_annotation/json_annotation.dart';

/// The four platform roles, ordered by privilege:
/// `superadmin` > `companyAdmin` > `employee` > `guest`.
///
/// Mirrors the backend's `role` field on `UserProfileSerializer` — keep the
/// `@JsonValue` wire names in sync with `apps/users/models.py`.
enum UserRole {
  @JsonValue('superadmin')
  superadmin,
  @JsonValue('company_admin')
  companyAdmin,
  @JsonValue('employee')
  employee,
  @JsonValue('guest')
  guest,
}
