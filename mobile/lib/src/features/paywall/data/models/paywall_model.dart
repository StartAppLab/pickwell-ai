import 'package:freezed_annotation/freezed_annotation.dart';

part 'paywall_model.freezed.dart';
part 'paywall_model.g.dart';

@freezed
abstract class PaywallModel with _$PaywallModel {
  const factory PaywallModel({required int id, required String message}) = _PaywallModel;

  factory PaywallModel.fromJson(Map<String, dynamic> json) => _$PaywallModelFromJson(json);
}
