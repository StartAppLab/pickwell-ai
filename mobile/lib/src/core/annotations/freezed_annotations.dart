import 'package:freezed_annotation/freezed_annotation.dart';

const Freezed freezedBlocState = Freezed(
  copyWith: true,
  equal: true,
  toStringOverride: true,
  makeCollectionsUnmodifiable: true,
  map: FreezedMapOptions.none,
);
