import 'package:askdev/core/routes/app_router.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void configureDependencies() {
  sl.registerLazySingleton<AppRouter>(AppRouter.new);
}