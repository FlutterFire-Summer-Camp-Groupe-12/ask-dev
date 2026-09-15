import 'package:askdev/core/routes/app_router.dart';
import 'package:askdev/core/routes/guards/auth_guard.dart';
import 'package:askdev/core/session/auth_gateway.dart';
import 'package:askdev/core/utils/app_logger.dart';
import 'package:askdev/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:askdev/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:askdev/features/auth/data/sources/auth_remote_data_source_impl.dart';
import 'package:askdev/features/auth/domain/repositories/auth_repository.dart';
import 'package:askdev/features/auth/presentation/manager/auth_cubit.dart';
import 'package:askdev/features/forum/data/repositories/media_repository_impl.dart';
import 'package:askdev/features/forum/data/repositories/question_repository_impl.dart';
import 'package:askdev/features/forum/data/sources/media_remote_data_source.dart';
import 'package:askdev/features/forum/data/sources/media_remote_data_source_impl.dart';
import 'package:askdev/features/forum/data/sources/question_remote_data_source.dart';
import 'package:askdev/features/forum/data/sources/question_remote_data_source_impl.dart';
import 'package:askdev/features/forum/domain/repositories/media_repository.dart';
import 'package:askdev/features/forum/domain/repositories/question_repository.dart';
import 'package:askdev/features/forum/domain/usecases/create_question.dart';
import 'package:askdev/features/forum/domain/usecases/create_answer.dart';
import 'package:askdev/features/forum/domain/usecases/update_answer.dart';
import 'package:askdev/features/forum/domain/usecases/delete_answer.dart';
import 'package:askdev/features/forum/domain/usecases/get_answers.dart';
import 'package:askdev/features/forum/domain/usecases/get_question_by_id.dart';
import 'package:askdev/features/forum/domain/usecases/get_recent_questions.dart';
import 'package:askdev/features/forum/domain/usecases/get_user_activity.dart';
import 'package:askdev/features/forum/domain/usecases/upload_image.dart';
import 'package:askdev/features/forum/domain/usecases/search_questions.dart';
import 'package:askdev/features/forum/domain/usecases/update_question.dart';
import 'package:askdev/features/forum/domain/usecases/delete_question.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/question_list_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/user_activity_cubit.dart';
import 'package:askdev/features/profile/data/sources/user_remote_data_source.dart';
import 'package:askdev/features/profile/data/sources/user_remote_data_source_impl.dart';
import 'package:askdev/features/profile/presentation/manager/profile_cubit.dart';
import 'package:askdev/features/settings/presentation/manager/settings_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
      userDataSource: sl<UserRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
      auth: FirebaseAuth.instance,
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
  sl.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(dataSource: sl<UserRemoteDataSource>()),
  );
  sl.registerLazySingleton<SettingsCubit>(SettingsCubit.new);
  sl.registerLazySingleton<QuestionRemoteDataSource>(
    () => QuestionRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(
      remoteDataSource: sl<QuestionRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetRecentQuestions>(
    () => GetRecentQuestions(sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<CreateQuestion>(
    () => CreateQuestion(repository: sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<GetQuestionById>(
    () => GetQuestionById(sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<GetAnswers>(
    () => GetAnswers(sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<CreateAnswer>(
    () => CreateAnswer(sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<SearchQuestions>(
    () => SearchQuestions(sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<UpdateAnswer>(
    () => UpdateAnswer(sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<DeleteAnswer>(
    () => DeleteAnswer(sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<UpdateQuestion>(
    () => UpdateQuestion(sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<DeleteQuestion>(
    () => DeleteQuestion(sl<QuestionRepository>()),
  );
  sl.registerLazySingleton<MediaRemoteDataSource>(
    () => MediaRemoteDataSourceImpl(storage: FirebaseStorage.instance),
  );
  sl.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(
      remoteDataSource: sl<MediaRemoteDataSource>(),
      authGateway: sl<AuthGateway>(),
    ),
  );
  sl.registerLazySingleton<UploadImage>(
    () => UploadImage(sl<MediaRepository>()),
  );
  sl.registerLazySingleton<GetUserActivity>(
    () => GetUserActivity(sl<QuestionRepository>()),
  );
  sl.registerFactory<UserActivityCubit>(
    () => UserActivityCubit(sl<GetUserActivity>()),
  );
  sl.registerFactory<QuestionListCubit>(
    () => QuestionListCubit(
      getRecentQuestions: sl<GetRecentQuestions>(),
      searchQuestions: sl<SearchQuestions>(),
    ),
  );
  // Un cubit par ouverture du formulaire : chaque brouillon repart vide.
  sl.registerFactory<AskQuestionCubit>(
    () => AskQuestionCubit(
      createQuestion: sl<CreateQuestion>(),
      authGateway: sl<AuthGateway>(),
    ),
  );
}
