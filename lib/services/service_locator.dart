import 'package:get_it/get_it.dart';
import 'package:mono_story/services/app_database/app_database_service.dart';
import 'package:mono_story/services/app_database/app_database_service_impl.dart';
import 'package:mono_story/services/icloud_storage/icloud_storage_service.dart';
import 'package:mono_story/services/icloud_storage/icloud_storage_service_impl.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/searched_message_viewmodel.dart';
import 'package:mono_story/view_models/settings_viewmodel.dart';
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
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
  //
  // View Model
  //
  serviceLocator.registerSingletonWithDependencies<StoryViewModel>(
    () => StoryViewModel(),
    dependsOn: [AppDatabaseService, IcloudStorageService],
  );
  serviceLocator.registerSingletonWithDependencies<SearchedMessageViewModel>(
    () => SearchedMessageViewModel(),
    dependsOn: [AppDatabaseService],
  );
  serviceLocator.registerSingletonWithDependencies<StarredMessageViewModel>(
    () => StarredMessageViewModel(),
    dependsOn: [AppDatabaseService],
  );
  serviceLocator.registerSingletonWithDependencies<ThreadViewModel>(
    () => ThreadViewModel(),
    dependsOn: [AppDatabaseService],
  );
  serviceLocator.registerSingletonAsync<SettingsViewModel>(
    () async {
      SettingsViewModel settingsVM = SettingsViewModel();
      return await settingsVM.init();
    },
  );
}
