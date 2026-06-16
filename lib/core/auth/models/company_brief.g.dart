// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_brief.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompanyBriefImpl _$$CompanyBriefImplFromJson(Map<String, dynamic> json) =>
    _$CompanyBriefImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      onboardingCompleted: json['onboarding_completed'] as bool,
    );

Map<String, dynamic> _$$CompanyBriefImplToJson(_$CompanyBriefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'onboarding_completed': instance.onboardingCompleted,
    };
