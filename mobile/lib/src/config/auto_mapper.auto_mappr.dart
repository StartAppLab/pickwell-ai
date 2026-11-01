// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// AutoMapprGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes, type=lint
// ignore_for_file: unnecessary_cast, unused_local_variable

import 'package:auto_mappr_annotation/auto_mappr_annotation.dart' as _i1;
import 'package:pickwell/src/features/auth/data/models/user_model.dart'
    as _i3;
import 'package:pickwell/src/features/auth/domain/entities/user_entity.dart'
    as _i2;

/// {@template package:pickwell/src/config/auto_mapper.dart}
/// Available mappings:
/// - `UserEntity` → `UserModel`.
/// - `UserModel` → `UserEntity`.
/// {@endtemplate}
class $AutoMapper implements _i1.AutoMapprInterface {
  const $AutoMapper();

  Type _typeOf<T>() => T;

  List<_i1.AutoMapprInterface> get _delegates => const [];

  /// {@macro AutoMapprInterface:canConvert}
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  bool canConvert<SOURCE, TARGET>({bool recursive = true}) {
    final sourceTypeOf = _typeOf<SOURCE>();
    final targetTypeOf = _typeOf<TARGET>();
    if ((sourceTypeOf == _typeOf<_i2.UserEntity>() ||
            sourceTypeOf == _typeOf<_i2.UserEntity?>()) &&
        (targetTypeOf == _typeOf<_i3.UserModel>() ||
            targetTypeOf == _typeOf<_i3.UserModel?>())) {
      return true;
    }
    if ((sourceTypeOf == _typeOf<_i3.UserModel>() ||
            sourceTypeOf == _typeOf<_i3.UserModel?>()) &&
        (targetTypeOf == _typeOf<_i2.UserEntity>() ||
            targetTypeOf == _typeOf<_i2.UserEntity?>())) {
      return true;
    }
    if (recursive) {
      for (final mappr in _delegates) {
        if (mappr.canConvert<SOURCE, TARGET>()) {
          return true;
        }
      }
    }
    return false;
  }

  /// {@macro AutoMapprInterface:convert}
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  TARGET convert<SOURCE, TARGET>(SOURCE? model) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return _convert(model)!;
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.convert(model)!;
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// {@macro AutoMapprInterface:tryConvert}
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  TARGET? tryConvert<SOURCE, TARGET>(
    SOURCE? model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
    onMappingError,
  }) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return _safeConvert(model, onMappingError: onMappingError);
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.tryConvert(model, onMappingError: onMappingError);
      }
    }

    return null;
  }

  /// {@macro AutoMapprInterface:convertIterable}
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  Iterable<TARGET> convertIterable<SOURCE, TARGET>(Iterable<SOURCE?> model) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return model.map<TARGET>((item) => _convert(item)!);
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.convertIterable(model);
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// For iterable items, converts from SOURCE to TARGET if such mapping is configured, into Iterable.
  ///
  /// When an item in the source iterable is null, uses `whenSourceIsNull` if defined or null
  ///
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  Iterable<TARGET?> tryConvertIterable<SOURCE, TARGET>(
    Iterable<SOURCE?> model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
    onMappingError,
  }) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return model.map<TARGET?>(
        (item) => _safeConvert(item, onMappingError: onMappingError),
      );
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.tryConvertIterable(model, onMappingError: onMappingError);
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// {@macro AutoMapprInterface:convertList}
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  List<TARGET> convertList<SOURCE, TARGET>(Iterable<SOURCE?> model) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return convertIterable<SOURCE, TARGET>(model).toList();
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.convertList(model);
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// For iterable items, converts from SOURCE to TARGET if such mapping is configured, into List.
  ///
  /// When an item in the source iterable is null, uses `whenSourceIsNull` if defined or null
  ///
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  List<TARGET?> tryConvertList<SOURCE, TARGET>(
    Iterable<SOURCE?> model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
    onMappingError,
  }) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return tryConvertIterable<SOURCE, TARGET>(
        model,
        onMappingError: onMappingError,
      ).toList();
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.tryConvertList(model, onMappingError: onMappingError);
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// {@macro AutoMapprInterface:convertSet}
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  Set<TARGET> convertSet<SOURCE, TARGET>(Iterable<SOURCE?> model) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return convertIterable<SOURCE, TARGET>(model).toSet();
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.convertSet(model);
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  /// For iterable items, converts from SOURCE to TARGET if such mapping is configured, into Set.
  ///
  /// When an item in the source iterable is null, uses `whenSourceIsNull` if defined or null
  ///
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  Set<TARGET?> tryConvertSet<SOURCE, TARGET>(
    Iterable<SOURCE?> model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
    onMappingError,
  }) {
    if (canConvert<SOURCE, TARGET>(recursive: false)) {
      return tryConvertIterable<SOURCE, TARGET>(
        model,
        onMappingError: onMappingError,
      ).toSet();
    }
    for (final mappr in _delegates) {
      if (mappr.canConvert<SOURCE, TARGET>()) {
        return mappr.tryConvertSet(model, onMappingError: onMappingError);
      }
    }

    throw Exception('No ${_typeOf<SOURCE>()} -> ${_typeOf<TARGET>()} mapping.');
  }

  TARGET? _convert<SOURCE, TARGET>(
    SOURCE? model, {
    bool canReturnNull = false,
  }) {
    final sourceTypeOf = _typeOf<SOURCE>();
    final targetTypeOf = _typeOf<TARGET>();
    if ((sourceTypeOf == _typeOf<_i2.UserEntity>() ||
            sourceTypeOf == _typeOf<_i2.UserEntity?>()) &&
        (targetTypeOf == _typeOf<_i3.UserModel>() ||
            targetTypeOf == _typeOf<_i3.UserModel?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i2$UserEntity_To__i3$UserModel((model as _i2.UserEntity?))
          as TARGET);
    }
    if ((sourceTypeOf == _typeOf<_i3.UserModel>() ||
            sourceTypeOf == _typeOf<_i3.UserModel?>()) &&
        (targetTypeOf == _typeOf<_i2.UserEntity>() ||
            targetTypeOf == _typeOf<_i2.UserEntity?>())) {
      if (canReturnNull && model == null) {
        return null;
      }
      return (_map__i3$UserModel_To__i2$UserEntity((model as _i3.UserModel?))
          as TARGET);
    }
    throw Exception('No ${model.runtimeType} -> $targetTypeOf mapping.');
  }

  TARGET? _safeConvert<SOURCE, TARGET>(
    SOURCE? model, {
    void Function(Object error, StackTrace stackTrace, SOURCE? source)?
    onMappingError,
  }) {
    if (!useSafeMapping<SOURCE, TARGET>()) {
      return _convert(model, canReturnNull: true);
    }
    try {
      return _convert(model, canReturnNull: true);
    } catch (e, s) {
      onMappingError?.call(e, s, model);
      return null;
    }
  }

  /// {@macro AutoMapprInterface:useSafeMapping}
  /// {@macro package:pickwell/src/config/auto_mapper.dart}
  @override
  bool useSafeMapping<SOURCE, TARGET>() {
    return false;
  }

  _i3.UserModel _map__i2$UserEntity_To__i3$UserModel(_i2.UserEntity? input) {
    final model = input;
    if (model == null) {
      throw Exception(
        r'Mapping UserEntity → UserModel failed because UserEntity was null, and no default value was provided. '
        r'Consider setting the whenSourceIsNull parameter on the MapType<UserEntity, UserModel> to handle null values during mapping.',
      );
    }
    return _i3.UserModel(
      id: model.id,
      displayName: model.displayName,
      email: model.email,
      phone: model.phone,
      created: model.created,
      lastSignIn: model.lastSignIn,
    );
  }

  _i2.UserEntity _map__i3$UserModel_To__i2$UserEntity(_i3.UserModel? input) {
    final model = input;
    if (model == null) {
      throw Exception(
        r'Mapping UserModel → UserEntity failed because UserModel was null, and no default value was provided. '
        r'Consider setting the whenSourceIsNull parameter on the MapType<UserModel, UserEntity> to handle null values during mapping.',
      );
    }
    return _i2.UserEntity(
      id: model.id,
      displayName: model.displayName,
      email: model.email,
      phone: model.phone,
      created: model.created,
      lastSignIn: model.lastSignIn,
    );
  }
}
