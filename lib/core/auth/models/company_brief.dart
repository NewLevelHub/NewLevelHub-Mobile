// ignore_for_file: invalid_annotation_target
// `@JsonKey` on freezed constructor params is valid for codegen but trips
// this analyzer lint — see https://github.com/rrousselGit/freezed/issues/488.
import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_brief.freezed.dart';
part 'company_brief.g.dart';

/// Minimal company reference embedded in [User]. `null` for guests and
/// building staff (`reception`/`service_manager`), who have no company.
@freezed
class CompanyBrief with _$CompanyBrief {
  const factory CompanyBrief({
    required int id,
    required String name,
    @JsonKey(name: 'onboarding_completed') required bool onboardingCompleted,
  }) = _CompanyBrief;

  factory CompanyBrief.fromJson(Map<String, dynamic> json) =>
      _$CompanyBriefFromJson(json);
}
