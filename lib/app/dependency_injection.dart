import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nesab/core/theme/cubit/theme_cubit.dart';
import 'package:nesab/core/localization/cubit/locale_cubit.dart';
import 'package:nesab/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:nesab/features/auth/data/data_sources/user_remote_data_source.dart';
import 'package:nesab/features/auth/data/data_sources/firestore_user_remote_data_source.dart';
import 'package:nesab/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nesab/features/auth/domain/repositories/auth_repository.dart';
import 'package:nesab/features/auth/domain/usecases/change_password.dart';
import 'package:nesab/features/auth/domain/usecases/get_current_user.dart';
import 'package:nesab/features/auth/domain/usecases/register_with_email.dart';
import 'package:nesab/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:nesab/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:nesab/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:nesab/features/auth/domain/usecases/reset_password.dart';
import 'package:nesab/features/auth/domain/usecases/sign_out.dart';
import 'package:nesab/features/auth/domain/usecases/delete_account.dart';
import 'package:nesab/features/auth/domain/usecases/update_profile.dart';
import 'package:nesab/features/auth/domain/usecases/upload_signature.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/profile/presentation/cubit/change_password_cubit.dart';
import 'package:nesab/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:nesab/features/profile/presentation/cubit/upload_signature_cubit.dart';



import 'package:nesab/core/services/analytics_service.dart';
import 'package:nesab/core/services/local_signature_service.dart';
import 'package:nesab/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:nesab/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:nesab/features/categories/domain/repositories/categories_repository.dart';
import 'package:nesab/features/categories/presentation/cubit/categories_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Theme & Locale
  getIt.registerFactory<ThemeCubit>(
    () => ThemeCubit(getIt<SharedPreferences>()),
  );
  getIt.registerFactory<LocaleCubit>(
    () => LocaleCubit(getIt<SharedPreferences>()),
  );

  // Analytics
  getIt.registerLazySingleton<FirebaseAnalytics>(
    () => FirebaseAnalytics.instance,
  );
  getIt.registerLazySingleton<AnalyticsService>(
    () => AnalyticsService(getIt<FirebaseAnalytics>()),
  );

  // Auth - External dependencies
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(
    () => FirebaseStorage.instance,
  );

  // Auth - Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(
      firebaseAuth: getIt<FirebaseAuth>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => FirestoreUserRemoteDataSource(
      firestore: getIt<FirebaseFirestore>(),
      storage: getIt<FirebaseStorage>(),
    ),
  );

  // Auth - Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<UserRemoteDataSource>(),
    ),
  );

  // Auth - Use cases
  getIt.registerFactory<SignInWithEmailUseCase>(
    () => SignInWithEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<RegisterWithEmailUseCase>(
    () => RegisterWithEmailUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignInWithAppleUseCase>(
    () => SignInWithAppleUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<SignOutUseCase>(
    () => SignOutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<DeleteAccountUseCase>(
    () => DeleteAccountUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<UploadSignatureUseCase>(
    () => UploadSignatureUseCase(getIt<AuthRepository>()),
  );

  // Auth - Cubit
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      signInWithEmailUseCase: getIt<SignInWithEmailUseCase>(),
      registerWithEmailUseCase: getIt<RegisterWithEmailUseCase>(),
      signInWithGoogleUseCase: getIt<SignInWithGoogleUseCase>(),
      signInWithAppleUseCase: getIt<SignInWithAppleUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      deleteAccountUseCase: getIt<DeleteAccountUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
      analyticsService: getIt<AnalyticsService>(),
    ),
  );

  // Profile
  getIt.registerFactory<EditProfileCubit>(
    () => EditProfileCubit(
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
    ),
  );
  getIt.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(
      changePasswordUseCase: getIt<ChangePasswordUseCase>(),
    ),
  );
  getIt.registerFactory<UploadSignatureCubit>(
    () => UploadSignatureCubit(
      localSignatureService: getIt<LocalSignatureService>(),
    ),
  );

  // Local Signature Service
  getIt.registerLazySingleton<LocalSignatureService>(
    () => LocalSignatureService(),
  );

 

  // Categories (Firestore + local fallback)
  getIt.registerLazySingleton<CategoriesRemoteDataSource>(
    () => FirestoreCategoriesRemoteDataSource(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(getIt<CategoriesRemoteDataSource>()),
  );
  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(getIt<CategoriesRepository>()),
  );

}
