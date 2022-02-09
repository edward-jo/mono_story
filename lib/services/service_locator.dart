import 'package:get_it/get_it.dart';
import 'package:mono_story/services/app_database/app_database_service.dart';
import 'package:mono_story/services/app_database/app_database_service_impl.dart';
import 'package:mono_story/services/icloud_storage/icloud_storage_service.dart';
import 'package:mono_story/services/icloud_storage/icloud_storage_service_impl.dart';
import 'package:mono_story/view_models/message_search_viewmodel.dart';
import 'package:mono_story/view_models/message_star_viewmodel.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';

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
  serviceLocator.registerSingletonWithDependencies<MessageSearchViewModel>(
    () => MessageSearchViewModel(),
    dependsOn: [AppDatabaseService],
  );
  serviceLocator.registerSingletonWithDependencies<MessageStarViewModel>(
    () => MessageStarViewModel(),
    dependsOn: [AppDatabaseService],
  );
  serviceLocator.registerSingletonWithDependencies<ThreadViewModel>(
    () => ThreadViewModel(),
    dependsOn: [AppDatabaseService],
  );
}
