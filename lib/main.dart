import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mono_story/services/service_locator.dart';
import 'package:mono_story/ui/common/modal_page_route.dart';
import 'package:mono_story/ui/common/platform_widget.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:mono_story/ui/theme/themes.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';
import 'package:mono_story/ui/views/main/main_screen.dart';
import 'package:mono_story/view_models/searched_message_viewmodel.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:mono_story/view_models/starred_message_viewmodel.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  setupServiceLocator();
  runApp(const MyApp());
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

        // -- ALERT DIALOG --
        if (snapshot.hasError) {
          return StyledBuilderErrorWidget(
            message: snapshot.error.toString(),
          );
        }

        // -- START MY APP --
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: serviceLocator<MessageViewModel>(),
            ),
            ChangeNotifierProvider.value(
              value: serviceLocator<SearchedMessageViewModel>(),
            ),
            ChangeNotifierProvider.value(
              value: serviceLocator<StarredMessageViewModel>(),
            ),
            ChangeNotifierProvider.value(
              value: serviceLocator<ThreadViewModel>(),
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

          /// Example
          // case NewMessageScreen.routeName:
          //   return MaterialPageRoute(
          //     settings: settings,
          //     builder: (context) => const NewMessageScreen(),
          //   );
        }
      },
    );
  }
}
