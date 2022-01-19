import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'ui/common/platform_widget.dart';
import 'ui/theme/themes.dart';
import 'ui/views/main/main_screen.dart';
import 'services/service_locator.dart';
import 'view_models/message_viewmodel.dart';

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
          showDialog(
              context: ctx,
              builder: (_) {
                return PlatformWidget(
                  cupertino: CupertinoAlertDialog(
                    content: Text(snapshot.error.toString()),
                  ),
                  material: AlertDialog(
                    content: Text(snapshot.error.toString()),
                  ),
                );
              });
          return Container();
        }

        // -- START MY APP --
        return ChangeNotifierProvider.value(
          value: serviceLocator<MessageViewModel>(),
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
    );
  }
}
