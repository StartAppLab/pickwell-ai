import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';

@freezed
abstract class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({required int id, required String message}) =
      _NotificationEntity;

  factory NotificationEntity.empty() => const NotificationEntity(id: 0, message: '');
}
