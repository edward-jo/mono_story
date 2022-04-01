import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mono_story/services/service_locator.dart';
import 'package:mono_story/ui/common/modal_page_route.dart';
import 'package:mono_story/ui/common/platform_widget.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/ui/theme/themes.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';
import 'package:mono_story/ui/views/main/main_screen.dart';
import 'package:mono_story/ui/views/main/settings/about/about_screen.dart';
import 'package:mono_story/ui/views/main/settings/backup_restore/backup_restore_screen.dart';
import 'package:mono_story/ui/views/main/settings/thread_settings/thread_setting_screen.dart';
import 'package:mono_story/view_models/searched_message_viewmodel.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/settings_viewmodel.dart';
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment
  await dotenv.load();
  // Create service locator(get_it)
  setupServiceLocator();
  // License
  LicenseRegistry.addLicense(_licenseCollector);
  // Orientations > Run app
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(const MyApp()));
}

Stream<LicenseEntry> _licenseCollector() async* {
  final license = await rootBundle.loadString(
    'assets/google_fonts/RobotoMono-LICENSE.txt',
  );
  yield LicenseEntryWithLineBreaks(['google_fonts'], license);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: serviceLocator.allReady(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // -- INDICATOR --
          return Container(
            color: Colors.white,
            child: const Center(
              child: PlatformWidget(
                cupertino: CupertinoActivityIndicator(),
                material: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          );
        }

        // -- ERROR MESSAGE --
        if (snapshot.hasError) {
          return StyledBuilderErrorWidget(
            message: snapshot.error.toString(),
          );
        }

        // -- START MY APP --
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: serviceLocator<StoryViewModel>(),
            ),
            ChangeNotifierProvider.value(
              value: serviceLocator<SearchedMessageViewModel>(),
            ),
            ChangeNotifierProvider.value(
              value: serviceLocator<StarredMessageViewModel>(),
            ),
            ChangeNotifierProvider.value(
              value: serviceLocator<ThreadViewModel>(),
            ),
            ChangeNotifierProvider.value(
              value: serviceLocator<SettingsViewModel>(),
            )
          ],
          child: const StartMyApp(),
        );
      },
    );
  }
}

class StartMyApp extends StatelessWidget {
  const StartMyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mono Story',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case NewMessageScreen.routeName:
            return ModalPageRoute(
              settings: settings,
              child: const NewMessageScreen(),
            );
          case ThreadSettingScreen.routeName:
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => const ThreadSettingScreen(),
            );
          case AboutScreen.routeName:
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => const AboutScreen(),
            );
          case BackupRestoreScreen.routeName:
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => const BackupRestoreScreen(),
            );
        }
      },
    );
  }
}
