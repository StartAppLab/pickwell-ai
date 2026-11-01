// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) =>
    _ProfileModel(id: (json['id'] as num).toInt(), message: json['message'] as String);

Map<String, dynamic> _$ProfileModelToJson(_ProfileModel instance) => <String, dynamic>{
  'id': instance.id,
  'message': instance.message,
};
