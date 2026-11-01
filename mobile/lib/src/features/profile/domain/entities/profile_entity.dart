import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_entity.freezed.dart';

@freezed
abstract class ProfileEntity with _$ProfileEntity {
  const factory ProfileEntity({required int id, required String message}) = _ProfileEntity;

  factory ProfileEntity.empty() => const ProfileEntity(id: 0, message: '');
}
