import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/database/_database.dart';
import '../features/paywall/data/data_sources/services/revenue_cat_service.dart';
import '_config.dart';

@module
abstract class RegisterModule {
  @Named('features')
  AppFeatures get features => AppFlavor.config.features;

  @lazySingleton
  BillingClient get billingClient => RevenueCatService.instance;
  @Named('baseUrl')
  String get baseUrl => AppFlavor.config.baseUrl;

  @Named('apiKey')
  String get apiKey => AppFlavor.config.apiKey;

  @Named('sentryDsn')
  String get sentryDsn => AppFlavor.config.sentryDsn;

  @Named('postHogApiKey')
  String get postHogApiKey => AppFlavor.config.postHogApiKey;

  @Named('postHogHost')
  String get postHogHost => AppFlavor.config.postHogHost;

  @Named('revenueCatAndroidApiKey')
  String get revenueCatAndroidApiKey => AppFlavor.config.revenueCatAndroidApiKey;

  @Named('revenueCatiOSApiKey')
  String get revenueCatiOSApiKey => AppFlavor.config.revenueCatiOSApiKey;

  @Named('revenueCatEntitlementId')
  String get revenueCatEntitlementId => AppFlavor.config.revenueCatEntitlementId;

  @lazySingleton
  DeviceInfoPlugin get deviceInfo => DeviceInfoPlugin();

  @lazySingleton
  Future<PackageInfo> packageInfo() async => await PackageInfo.fromPlatform();

  @lazySingleton
  Logger get logger => Logger();

  @preResolve
  @lazySingleton
  Future<SharedPreferences> sharedPreferences() async => await SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(aOptions: AndroidOptions());

  @lazySingleton
  AppDatabase get appDatabase => AppDatabase();

  @lazySingleton
  InternetConnection get internetConnection => InternetConnection();

  @lazySingleton
  Dio dio(AppConfig config) => Dio()..options.baseUrl = config.baseUrl;

  @lazySingleton
  SupabaseClient get supabase => Supabase.instance.client;
}
