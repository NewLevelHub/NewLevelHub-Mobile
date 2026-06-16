// ignore_for_file: invalid_annotation_target
// `@JsonKey` on freezed constructor params is valid for codegen but trips
// this analyzer lint — see https://github.com/rrousselGit/freezed/issues/488.
import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_brief.dart';
import 'user_role.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Authenticated user profile. Mirrors the backend's
/// `UserProfileSerializer` (`apps/users/serializers.py`) — keep field names
/// and JSON keys in sync with it.
@freezed
class User with _$User {
  const factory User({
    required int id,
    required String email,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'full_name') required String fullName,
    String? phone,
    String? position,
    String? avatar,
    required UserRole role,
    CompanyBrief? company,
    @JsonKey(name: 'is_email_verified') required bool isEmailVerified,
    @JsonKey(name: 'date_joined') required DateTime dateJoined,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
