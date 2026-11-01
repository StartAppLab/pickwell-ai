import 'package:freezed_annotation/freezed_annotation.dart';

import '../annotations/_annotations.dart';
import '_types.dart';

part 'validated_string.freezed.dart';

@freezedBlocState
abstract class ValidatedString with _$ValidatedString {
  const factory ValidatedString({@Default('') String value, @Default(null) IsValid? isValid}) =
      _ValidatedString;

  const ValidatedString._();

  static const ValidatedString empty = ValidatedString();

  bool get isEmpty => this == empty;
}
