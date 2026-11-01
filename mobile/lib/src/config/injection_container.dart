import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit(initializerName: 'init', asExtension: false, preferRelativeImports: true)
Future<void> configureDependencies() async => await init(getIt);
