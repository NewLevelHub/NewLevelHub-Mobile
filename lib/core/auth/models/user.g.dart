// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      position: json['position'] as String?,
      avatar: json['avatar'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      company: json['company'] == null
          ? null
          : CompanyBrief.fromJson(json['company'] as Map<String, dynamic>),
      isEmailVerified: json['is_email_verified'] as bool,
      dateJoined: DateTime.parse(json['date_joined'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'position': instance.position,
      'avatar': instance.avatar,
      'role': _$UserRoleEnumMap[instance.role]!,
      'company': instance.company,
      'is_email_verified': instance.isEmailVerified,
      'date_joined': instance.dateJoined.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.superadmin: 'superadmin',
  UserRole.companyAdmin: 'company_admin',
  UserRole.employee: 'employee',
  UserRole.reception: 'reception',
  UserRole.serviceManager: 'service_manager',
  UserRole.guest: 'guest',
};
