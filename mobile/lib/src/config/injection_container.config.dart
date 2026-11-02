// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:device_info_plus/device_info_plus.dart' as _i833;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:logger/logger.dart' as _i974;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../core/_core.dart' as _i172;
import '../core/database/_database.dart' as _i1065;
import '../core/database/app_database.dart' as _i935;
import '../core/database/database_transaction_runner.dart' as _i437;
import '../core/network/network_info.dart' as _i6;
import '../core/storage/data_storage.dart' as _i926;
import '../core/storage/secure_storage.dart' as _i637;
import '../core/types/string_validator.dart' as _i726;
import '../core/utils/svg_cache.dart' as _i303;
import '../features/app/domain/validation/input_validators.dart' as _i630;
import '../features/auth/data/data_sources/_data_sources.dart' as _i586;
import '../features/auth/data/data_sources/auth_local_source.dart' as _i1062;
import '../features/auth/data/data_sources/auth_remote_source.dart' as _i520;
import '../features/auth/data/data_sources/services/_services.dart' as _i87;
import '../features/auth/data/data_sources/services/auth_api_service.dart'
    as _i176;
import '../features/auth/data/repositories/auth_repository.dart' as _i243;
import '../features/auth/domain/_domain.dart' as _i63;
import '../features/auth/domain/use_cases/change_password_use_case.dart'
    as _i544;
import '../features/auth/domain/use_cases/forgot_password_use_case.dart'
    as _i301;
import '../features/auth/domain/use_cases/otp_resend_use_case.dart' as _i507;
import '../features/auth/domain/use_cases/otp_verify_use_case.dart' as _i305;
import '../features/auth/domain/use_cases/sign_in_use_case.dart' as _i503;
import '../features/auth/domain/use_cases/sign_out_use_case.dart' as _i964;
import '../features/auth/domain/use_cases/sign_up_use_case.dart' as _i500;
import '../features/auth/presentation/blocs/change_password/change_password_cubit.dart'
    as _i358;
import '../features/auth/presentation/blocs/forgot_password/forgot_password_cubit.dart'
    as _i330;
import '../features/auth/presentation/blocs/otp/otp_cubit.dart' as _i119;
import '../features/auth/presentation/blocs/sign_in/sign_in_cubit.dart'
    as _i465;
import '../features/auth/presentation/blocs/sign_out/sign_out_cubit.dart'
    as _i829;
import '../features/auth/presentation/blocs/sign_up/sign_up_cubit.dart'
    as _i341;
import '../features/auth/presentation/services/auth_actions.dart' as _i945;
import '../features/catalog/data/data_sources/catalog_local_source.dart'
    as _i871;
import '../features/catalog/data/data_sources/catalog_remote_source.dart'
    as _i895;
import '../features/catalog/data/data_sources/services/catalog_api_service.dart'
    as _i988;
import '../features/catalog/data/data_sources/services/scanner_media_service.dart'
    as _i1007;
import '../features/catalog/data/repositories/catalog_repository.dart' as _i496;
import '../features/catalog/domain/_domain.dart' as _i721;
import '../features/catalog/domain/repositories/catalog_repository.dart'
    as _i919;
import '../features/catalog/domain/use_cases/get_catalog_use_case.dart'
    as _i670;
import '../features/catalog/presentation/blocs/catalog/catalog_cubit.dart'
    as _i1068;
import '../features/catalog/presentation/blocs/catalog/label_capture_cubit.dart'
    as _i84;
import '../features/home/presentation/blocs/home/home_cubit.dart' as _i641;
import '../features/notification/data/data_sources/_data_sources.dart' as _i66;
import '../features/notification/data/data_sources/notification_local_source.dart'
    as _i290;
import '../features/notification/data/data_sources/notification_remote_source.dart'
    as _i729;
import '../features/notification/data/data_sources/services/_services.dart'
    as _i884;
import '../features/notification/data/data_sources/services/notification_api_service.dart'
    as _i802;
import '../features/notification/data/repositories/notification_repository.dart'
    as _i634;
import '../features/notification/domain/_domain.dart' as _i841;
import '../features/notification/domain/use_cases/get_notification_use_case.dart'
    as _i81;
import '../features/notification/presentation/blocs/notification/notification_cubit.dart'
    as _i13;
import '../features/onboarding/presentation/blocs/onboarding/onboarding_cubit.dart'
    as _i883;
import '../features/paywall/data/_data.dart' as _i709;
import '../features/paywall/data/data_sources/_data_sources.dart' as _i348;
import '../features/paywall/data/data_sources/paywall_local_source.dart'
    as _i877;
import '../features/paywall/data/data_sources/paywall_remote_source.dart'
    as _i338;
import '../features/paywall/data/data_sources/services/_services.dart'
    as _i1014;
import '../features/paywall/data/data_sources/services/paywall_api_service.dart'
    as _i54;
import '../features/paywall/data/data_sources/services/revenue_cat_service.dart'
    as _i1027;
import '../features/paywall/data/repositories/paywall_repository.dart' as _i33;
import '../features/paywall/domain/_domain.dart' as _i602;
import '../features/paywall/domain/use_cases/get_paywall_use_case.dart'
    as _i386;
import '../features/paywall/presentation/blocs/paywall/paywall_cubit.dart'
    as _i315;
import '../features/paywall/presentation/blocs/subscription/subscription_cubit.dart'
    as _i452;
import '../features/paywall/presentation/services/paywall_gate_service.dart'
    as _i465;
import '../features/profile/data/data_sources/_data_sources.dart' as _i56;
import '../features/profile/data/data_sources/profile_local_source.dart'
    as _i445;
import '../features/profile/data/data_sources/profile_remote_source.dart'
    as _i141;
import '../features/profile/data/data_sources/services/_services.dart' as _i275;
import '../features/profile/data/data_sources/services/profile_api_service.dart'
    as _i834;
import '../features/profile/data/repositories/profile_repository.dart' as _i537;
import '../features/profile/domain/_domain.dart' as _i1017;
import '../features/profile/domain/use_cases/get_profile_use_case.dart'
    as _i483;
import '../features/profile/presentation/blocs/profile/profile_cubit.dart'
    as _i395;
import '../features/root/presentation/blocs/root/root_cubit.dart' as _i1012;
import '../features/settings/data/data_sources/_data_sources.dart' as _i1037;
import '../features/settings/data/data_sources/services/_services.dart'
    as _i682;
import '../features/settings/data/data_sources/services/settings_api_service.dart'
    as _i1039;
import '../features/settings/data/data_sources/settings_local_source.dart'
    as _i1001;
import '../features/settings/data/data_sources/settings_remote_source.dart'
    as _i1005;
import '../features/settings/data/repositories/settings_repository.dart'
    as _i1020;
import '../features/settings/domain/_domain.dart' as _i482;
import '../features/settings/domain/use_cases/get_settings_use_case.dart'
    as _i316;
import '../features/settings/presentation/blocs/settings/settings_cubit.dart'
    as _i159;
import '../features/settings/presentation/blocs/settings_account/settings_account_cubit.dart'
    as _i624;
import '../features/settings/presentation/blocs/settings_notifications/settings_notifications_cubit.dart'
    as _i1068;
import '_config.dart' as _i369;
import 'app_config.dart' as _i609;
import 'app_features.dart' as _i650;
import 'app_session.dart' as _i904;
import 'auto_mapper.dart' as _i322;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.factory<_i726.StringValidator>(() => _i726.StringValidator());
  gh.factory<_i630.InputValidators>(() => const _i630.InputValidators());
  gh.factory<_i1068.SettingsNotificationsCubit>(
    () => _i1068.SettingsNotificationsCubit(),
  );
  gh.lazySingleton<_i322.AutoMapper>(() => _i322.AutoMapper());
  gh.lazySingleton<_i1027.BillingClient>(() => registerModule.billingClient);
  gh.lazySingleton<_i833.DeviceInfoPlugin>(() => registerModule.deviceInfo);
  gh.lazySingleton<_i974.Logger>(() => registerModule.logger);
  gh.lazySingleton<_i558.FlutterSecureStorage>(
    () => registerModule.secureStorage,
  );
  gh.lazySingleton<_i1065.AppDatabase>(() => registerModule.appDatabase);
  gh.lazySingleton<_i161.InternetConnection>(
    () => registerModule.internetConnection,
  );
  gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabase);
  gh.lazySingletonAsync<_i655.PackageInfo>(() => registerModule.packageInfo());
  await gh.lazySingletonAsync<_i460.SharedPreferences>(
    () => registerModule.sharedPreferences(),
    preResolve: true,
  );
  gh.lazySingleton<_i303.SvgCache>(() => _i303.SvgCache());
  gh.lazySingleton<_i1007.ScannerMediaService>(
    () => _i1007.ScannerMediaService(),
  );
  gh.lazySingleton<_i1012.RootCubit>(() => _i1012.RootCubit());
  gh.factory<String>(
    () => registerModule.postHogHost,
    instanceName: 'postHogHost',
  );
  gh.factory<String>(
    () => registerModule.revenueCatAndroidApiKey,
    instanceName: 'revenueCatAndroidApiKey',
  );
  gh.factory<String>(
    () => registerModule.revenueCatEntitlementId,
    instanceName: 'revenueCatEntitlementId',
  );
  gh.factory<_i84.LabelCaptureCubit>(
    () => _i84.LabelCaptureCubit(gh<_i1007.ScannerMediaService>()),
  );
  gh.factory<String>(() => registerModule.sentryDsn, instanceName: 'sentryDsn');
  gh.factory<String>(
    () => registerModule.postHogApiKey,
    instanceName: 'postHogApiKey',
  );
  gh.factory<_i369.AppFeatures>(
    () => registerModule.features,
    instanceName: 'features',
  );
  gh.factory<String>(() => registerModule.baseUrl, instanceName: 'baseUrl');
  gh.factory<String>(
    () => registerModule.revenueCatiOSApiKey,
    instanceName: 'revenueCatiOSApiKey',
  );
  gh.lazySingleton<_i637.SecureStorage>(
    () => _i637.SecureStorage(storage: gh<_i558.FlutterSecureStorage>()),
  );
  gh.lazySingleton<_i437.DatabaseTransactionRunner>(
    () => _i437.DatabaseTransactionRunner(gh<_i935.AppDatabase>()),
  );
  gh.factory<String>(() => registerModule.apiKey, instanceName: 'apiKey');
  gh.lazySingleton<_i6.NetworkInfo>(
    () => _i6.NetworkInfo(connectionChecker: gh<_i161.InternetConnection>()),
  );
  gh.lazySingleton<_i926.DataStorage>(
    () => _i926.DataStorage(storage: gh<_i460.SharedPreferences>()),
  );
  gh.lazySingleton<_i871.CatalogLocalSource>(
    () => _i871.CatalogLocalSource(gh<_i926.DataStorage>()),
  );
  gh.lazySingleton<_i1062.AuthLocalSource>(
    () => _i1062.AuthLocalSource(storage: gh<_i172.DataStorage>()),
  );
  gh.lazySingleton<_i290.NotificationLocalSource>(
    () => _i290.NotificationLocalSource(storage: gh<_i172.DataStorage>()),
  );
  gh.lazySingleton<_i877.PaywallLocalSource>(
    () => _i877.PaywallLocalSource(storage: gh<_i172.DataStorage>()),
  );
  gh.lazySingleton<_i445.ProfileLocalSource>(
    () => _i445.ProfileLocalSource(storage: gh<_i172.DataStorage>()),
  );
  gh.lazySingleton<_i1001.SettingsLocalSource>(
    () => _i1001.SettingsLocalSource(storage: gh<_i172.DataStorage>()),
  );
  gh.singleton<_i609.AppConfig>(
    () => _i609.AppConfig(
      features: gh<_i650.AppFeatures>(instanceName: 'features'),
      baseUrl: gh<String>(instanceName: 'baseUrl'),
      apiKey: gh<String>(instanceName: 'apiKey'),
      sentryDsn: gh<String>(instanceName: 'sentryDsn'),
      postHogApiKey: gh<String>(instanceName: 'postHogApiKey'),
      postHogHost: gh<String>(instanceName: 'postHogHost'),
      revenueCatAndroidApiKey: gh<String>(
        instanceName: 'revenueCatAndroidApiKey',
      ),
      revenueCatiOSApiKey: gh<String>(instanceName: 'revenueCatiOSApiKey'),
      revenueCatEntitlementId: gh<String>(
        instanceName: 'revenueCatEntitlementId',
      ),
    ),
  );
  gh.lazySingleton<_i465.PaywallGateService>(
    () => _i465.PaywallGateService(
      gh<_i926.DataStorage>(),
      gh<_i460.SharedPreferences>(),
    ),
  );
  gh.factory<_i176.AuthApiService>(
    () => _i176.AuthApiServiceImpl(
      gh<_i454.SupabaseClient>(),
      gh<_i609.AppConfig>(),
    ),
  );
  gh.lazySingleton<_i883.OnboardingCubit>(
    () => _i883.OnboardingCubit(gh<_i172.DataStorage>()),
  );
  gh.lazySingleton<_i159.SettingsCubit>(
    () => _i159.SettingsCubit(gh<_i172.DataStorage>()),
  );
  gh.lazySingleton<_i520.AuthRemoteSource>(
    () => _i520.AuthRemoteSource(authApiService: gh<_i87.AuthApiService>()),
  );
  gh.lazySingleton<_i904.AppSession>(
    () => _i904.AppSession(gh<_i609.AppConfig>(), gh<_i926.DataStorage>()),
  );
  gh.lazySingleton<_i945.AuthActions>(
    () => _i945.AuthActions(
      gh<_i454.SupabaseClient>(),
      gh<_i369.AppConfig>(),
      gh<_i926.DataStorage>(),
    ),
  );
  gh.lazySingleton<_i361.Dio>(() => registerModule.dio(gh<_i369.AppConfig>()));
  gh.factory<_i1039.SettingsApiService>(
    () => _i1039.SettingsApiServiceImpl(gh<_i361.Dio>(), gh<_i369.AppConfig>()),
  );
  gh.factory<_i54.PaywallApiService>(
    () => _i54.PaywallApiServiceImpl(gh<_i361.Dio>(), gh<_i369.AppConfig>()),
  );
  gh.factory<_i834.ProfileApiService>(
    () => _i834.ProfileApiServiceImpl(gh<_i361.Dio>(), gh<_i369.AppConfig>()),
  );
  gh.lazySingleton<_i141.ProfileRemoteSource>(
    () => _i141.ProfileRemoteSource(
      profileApiService: gh<_i275.ProfileApiService>(),
    ),
  );
  gh.lazySingleton<_i988.CatalogApiService>(
    () => _i988.SupabaseCatalogApiService(gh<_i609.AppConfig>()),
  );
  gh.lazySingleton<_i1005.SettingsRemoteSource>(
    () => _i1005.SettingsRemoteSource(
      settingsApiService: gh<_i682.SettingsApiService>(),
    ),
  );
  gh.factory<_i63.AuthRepository>(
    () => _i243.AuthRepositoryImpl(
      localSource: gh<_i586.AuthLocalSource>(),
      remoteSource: gh<_i586.AuthRemoteSource>(),
      networkInfo: gh<_i172.NetworkInfo>(),
      autoMapper: gh<_i369.AutoMapper>(),
      storage: gh<_i172.DataStorage>(),
    ),
  );
  gh.lazySingleton<_i452.SubscriptionCubit>(
    () => _i452.SubscriptionCubit(
      gh<_i369.AppConfig>(),
      gh<_i709.BillingClient>(),
    ),
  );
  gh.factory<_i1017.ProfileRepository>(
    () => _i537.ProfileRepositoryImpl(
      localSource: gh<_i56.ProfileLocalSource>(),
      remoteSource: gh<_i56.ProfileRemoteSource>(),
      networkInfo: gh<_i172.NetworkInfo>(),
      autoMapper: gh<_i369.AutoMapper>(),
      storage: gh<_i172.DataStorage>(),
    ),
  );
  gh.lazySingleton<_i624.SettingsAccountCubit>(
    () => _i624.SettingsAccountCubit(gh<_i945.AuthActions>()),
  );
  gh.factory<_i802.NotificationApiService>(
    () => _i802.NotificationApiServiceImpl(
      gh<_i361.Dio>(),
      gh<_i369.AppConfig>(),
    ),
  );
  gh.factory<_i482.SettingsRepository>(
    () => _i1020.SettingsRepositoryImpl(
      localSource: gh<_i1037.SettingsLocalSource>(),
      remoteSource: gh<_i1037.SettingsRemoteSource>(),
      networkInfo: gh<_i172.NetworkInfo>(),
      autoMapper: gh<_i369.AutoMapper>(),
      storage: gh<_i172.DataStorage>(),
    ),
  );
  gh.factory<_i315.PaywallCubit>(
    () => _i315.PaywallCubit(
      gh<_i709.BillingClient>(),
      gh<_i369.AppConfig>(),
      gh<_i452.SubscriptionCubit>(),
    ),
  );
  gh.lazySingleton<_i544.ChangePasswordUseCase>(
    () => _i544.ChangePasswordUseCase(gh<_i63.AuthRepository>()),
  );
  gh.lazySingleton<_i301.ForgotPasswordUseCase>(
    () => _i301.ForgotPasswordUseCase(gh<_i63.AuthRepository>()),
  );
  gh.lazySingleton<_i507.OtpResendUseCase>(
    () => _i507.OtpResendUseCase(gh<_i63.AuthRepository>()),
  );
  gh.lazySingleton<_i305.OtpVerifyUseCase>(
    () => _i305.OtpVerifyUseCase(gh<_i63.AuthRepository>()),
  );
  gh.lazySingleton<_i503.SignInUseCase>(
    () => _i503.SignInUseCase(gh<_i63.AuthRepository>()),
  );
  gh.lazySingleton<_i964.SignOutUseCase>(
    () => _i964.SignOutUseCase(gh<_i63.AuthRepository>()),
  );
  gh.lazySingleton<_i500.SignUpUseCase>(
    () => _i500.SignUpUseCase(gh<_i63.AuthRepository>()),
  );
  gh.lazySingleton<_i341.SignUpCubit>(
    () => _i341.SignUpCubit(gh<_i63.SignUpUseCase>()),
  );
  gh.lazySingleton<_i338.PaywallRemoteSource>(
    () => _i338.PaywallRemoteSource(
      paywallApiService: gh<_i1014.PaywallApiService>(),
    ),
  );
  gh.lazySingleton<_i316.GetSettingsUseCase>(
    () => _i316.GetSettingsUseCase(gh<_i482.SettingsRepository>()),
  );
  gh.lazySingleton<_i330.ForgotPasswordCubit>(
    () => _i330.ForgotPasswordCubit(gh<_i63.ForgotPasswordUseCase>()),
  );
  gh.lazySingleton<_i829.SignOutCubit>(
    () => _i829.SignOutCubit(gh<_i63.SignOutUseCase>()),
  );
  gh.lazySingleton<_i483.GetProfileUseCase>(
    () => _i483.GetProfileUseCase(gh<_i1017.ProfileRepository>()),
  );
  gh.lazySingleton<_i895.CatalogRemoteSource>(
    () => _i895.CatalogRemoteSource(gh<_i988.CatalogApiService>()),
  );
  gh.lazySingleton<_i395.ProfileCubit>(
    () => _i395.ProfileCubit(gh<_i1017.GetProfileUseCase>()),
  );
  gh.lazySingleton<_i919.CatalogRepository>(
    () => _i496.CatalogRepositoryImpl(
      gh<_i871.CatalogLocalSource>(),
      gh<_i895.CatalogRemoteSource>(),
    ),
  );
  gh.lazySingleton<_i465.SignInCubit>(
    () => _i465.SignInCubit(gh<_i63.SignInUseCase>()),
  );
  gh.lazySingleton<_i119.OtpCubit>(
    () => _i119.OtpCubit(
      gh<_i63.OtpVerifyUseCase>(),
      gh<_i63.OtpResendUseCase>(),
    ),
  );
  gh.lazySingleton<_i729.NotificationRemoteSource>(
    () => _i729.NotificationRemoteSource(
      notificationApiService: gh<_i884.NotificationApiService>(),
    ),
  );
  gh.factory<_i602.PaywallRepository>(
    () => _i33.PaywallRepositoryImpl(
      localSource: gh<_i348.PaywallLocalSource>(),
      remoteSource: gh<_i348.PaywallRemoteSource>(),
      networkInfo: gh<_i172.NetworkInfo>(),
      autoMapper: gh<_i369.AutoMapper>(),
      storage: gh<_i172.DataStorage>(),
    ),
  );
  gh.lazySingleton<_i670.GetCatalogUseCase>(
    () => _i670.GetCatalogUseCase(gh<_i919.CatalogRepository>()),
  );
  gh.lazySingleton<_i670.GetRecentProductsUseCase>(
    () => _i670.GetRecentProductsUseCase(gh<_i919.CatalogRepository>()),
  );
  gh.lazySingleton<_i386.GetPaywallUseCase>(
    () => _i386.GetPaywallUseCase(gh<_i602.PaywallRepository>()),
  );
  gh.lazySingleton<_i358.ChangePasswordCubit>(
    () => _i358.ChangePasswordCubit(gh<_i63.ChangePasswordUseCase>()),
  );
  gh.lazySingleton<_i641.HomeCubit>(
    () => _i641.HomeCubit(gh<_i721.GetRecentProductsUseCase>()),
  );
  gh.factory<_i841.NotificationRepository>(
    () => _i634.NotificationRepositoryImpl(
      localSource: gh<_i66.NotificationLocalSource>(),
      remoteSource: gh<_i66.NotificationRemoteSource>(),
      networkInfo: gh<_i172.NetworkInfo>(),
      autoMapper: gh<_i369.AutoMapper>(),
      storage: gh<_i172.DataStorage>(),
    ),
  );
  gh.lazySingleton<_i81.GetNotificationUseCase>(
    () => _i81.GetNotificationUseCase(gh<_i841.NotificationRepository>()),
  );
  gh.lazySingleton<_i13.NotificationCubit>(
    () => _i13.NotificationCubit(gh<_i841.GetNotificationUseCase>()),
  );
  gh.factory<_i1068.CatalogCubit>(
    () => _i1068.CatalogCubit(gh<_i721.GetCatalogUseCase>()),
  );
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}
