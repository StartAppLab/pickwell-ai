import 'package:freezed_annotation/freezed_annotation.dart';

part 'paywall_entity.freezed.dart';

@freezed
abstract class PaywallEntity with _$PaywallEntity {
  const factory PaywallEntity({required int id, required String message}) = _PaywallEntity;

  factory PaywallEntity.empty() => const PaywallEntity(id: 0, message: '');
}
