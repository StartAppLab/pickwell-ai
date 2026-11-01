import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
abstract class UserEntity with _$UserEntity {
  const factory UserEntity({
    required int id,
    String? displayName,
    required String email,
    String? phone,
    required DateTime created,
    required DateTime lastSignIn,
  }) = _UserEntity;
}
