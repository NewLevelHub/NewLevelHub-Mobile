import 'package:json_annotation/json_annotation.dart';

/// The platform roles. `superadmin` > `companyAdmin` > `employee` outrank
/// `guest` in privilege; `reception` and `serviceManager` are building-staff
/// roles (no company, see `apps/users/models.py` `ROLE_CHOICES`) that sit
/// alongside `employee` rather than in the same admin/guest hierarchy.
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
  @JsonValue('reception')
  reception,
  @JsonValue('service_manager')
  serviceManager,
  @JsonValue('guest')
  guest,
}
