import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_brief.freezed.dart';
part 'company_brief.g.dart';

/// Minimal company reference embedded in [User]. `null` for guests, who have
/// no company.
@freezed
class CompanyBrief with _$CompanyBrief {
  const factory CompanyBrief({
    required int id,
    required String name,
  }) = _CompanyBrief;

  factory CompanyBrief.fromJson(Map<String, dynamic> json) =>
      _$CompanyBriefFromJson(json);
}
