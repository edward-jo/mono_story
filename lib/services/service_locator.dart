import 'package:get_it/get_it.dart';

import '/services/icloud_storage/icloud_storage_service.dart';
import '/services/icloud_storage/icloud_storage_service_impl.dart';
import '../view_models/message_viewmodel.dart';
import 'app_database/app_database_service.dart';
import 'app_database/app_database_service_impl.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  serviceLocator.registerSingletonAsync<AppDatabaseService>(() async {
    AppDatabaseService service = AppDatabaseServiceImpl();
    return await service.init();
  });
  serviceLocator.registerSingletonAsync<IcloudStorageService>(() async {
    IcloudStorageService service = IcloudStorageServiceImpl();
    return await service.init();
  });
  serviceLocator.registerSingletonWithDependencies<MessageViewModel>(
    () => MessageViewModel(),
    dependsOn: [AppDatabaseService, IcloudStorageService],
  );
}
