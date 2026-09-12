import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/routes/guards/auth_guard.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/core/utils/app_logger.dart';
import 'package:askdev/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:askdev/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:askdev/features/auth/data/sources/auth_remote_data_source_impl.dart';
import 'package:askdev/features/auth/domain/repositories/auth_repository.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/forum/data/repositories/question_repository_impl.dart';
import 'package:askdev/features/forum/data/sources/question_remote_source.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/usecases/get_recent_questions.dart';
import 'package:askdev/features/forum/presentation/manager/question_list_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

final sl = GetIt.instance;

void services() {
  final logger = AppLogger.init();
  logger.installGlobalHandlers();
  logger.info('Bootstrap', 'App starting');
}

void configureDependencies() {
  services();
  sl.registerLazySingleton<AppRouter>(AppRouter.new);
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<AuthGateway>(() => sl<AuthRepository>());
  sl.registerLazySingleton<AuthGuard>(
    () => AuthGuard(authGateway: sl<AuthGateway>()),
  );
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<QuestionRemoteSource>(
    () => QuestionRemoteSourceImpl(FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(sl<QuestionRemoteSource>()),
  );
  sl.registerLazySingleton(() => GetRecentQuestions(sl<QuestionRepository>()));
  sl.registerFactory<QuestionListCubit>(
    () => QuestionListCubit(sl<GetRecentQuestions>()),
  );
}