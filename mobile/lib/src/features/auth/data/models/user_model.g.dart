// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: (json['userUID'] as num).toInt(),
  displayName: json['displayName'] as String?,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  created: DateTime.parse(json['created'] as String),
  lastSignIn: DateTime.parse(json['lastSignIn'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) => <String, dynamic>{
  'userUID': instance.id,
  'displayName': instance.displayName,
  'email': instance.email,
  'phone': instance.phone,
  'created': instance.created.toIso8601String(),
  'lastSignIn': instance.lastSignIn.toIso8601String(),
};
