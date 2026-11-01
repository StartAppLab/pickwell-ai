import 'package:injectable/injectable.dart';

import 'app_database.dart';

@lazySingleton
class DatabaseTransactionRunner {
  final AppDatabase database;

  @factoryMethod
  const DatabaseTransactionRunner(this.database);

  Future<T> run<T>(Future<T> Function() action) {
    return database.transaction(action);
  }
}
