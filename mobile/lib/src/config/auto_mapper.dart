import 'package:auto_mappr_annotation/auto_mappr_annotation.dart';
import 'package:injectable/injectable.dart';

import '../features/_features.dart';
import 'auto_mapper.auto_mappr.dart';

@lazySingleton
@AutoMappr([MapType<UserEntity, UserModel>(reverse: true)])
class AutoMapper extends $AutoMapper {
  @override
  bool useSafeMapping<SOURCE, TARGET>() {
    return false;
  }
}
