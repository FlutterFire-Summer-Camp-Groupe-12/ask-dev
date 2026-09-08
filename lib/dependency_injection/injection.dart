import 'package:askdev/core/routes/app_router.dart';
import 'package:get_it/get_it.dart';

import '../core/utils/app_logger.dart';

final sl = GetIt.instance;

void services() {
  final logger = AppLogger.init();
  logger.installGlobalHandlers();
  logger.info('Bootstrap', 'App starting');
}

void configureDependencies() {
  sl.registerLazySingleton<AppRouter>(AppRouter.new);
}
