import 'package:freezed_annotation/freezed_annotation.dart';

part 'preoccupation.freezed.dart';

/// A worry the user has put down, as seen by the UI.
///
/// This is a DERIVED projection rebuilt from the event log (never a stored
/// Hive type — it allocates no `typeId`). [mentalWeightKg] is `null` while the
/// item is genuinely pending AI analysis (Story 2.3 assigns it, frozen +
/// versioned); `null` MUST stay distinguishable from any neutral floor value
/// the AI fallback might use. The analysis fields ([category], [effortScore],
/// [estimatedDurationMinutes], [weightModelVersion]) are likewise `null` until
/// a `weight.assigned` event is folded in.
@freezed
abstract class Preoccupation with _$Preoccupation {
  /// Creates a projected preoccupation.
  const factory Preoccupation({
    required String id,
    required String content,
    required DateTime createdAt,
    int? mentalWeightKg,
    String? category,
    int? effortScore,
    int? estimatedDurationMinutes,
    String? weightModelVersion,
  }) = _Preoccupation;

  const Preoccupation._();

  /// Whether the Mental Weight has not been assigned yet (awaiting analysis).
  bool get isPending => mentalWeightKg == null;
}
