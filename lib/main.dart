import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'ui/views/main/main_screen.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MonoPlatformApp();
  }
}

class MonoPlatformApp extends StatelessWidget {
  const MonoPlatformApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      cupertino: (_, __) => const CupertinoApp(
        title: 'Mono Story',
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
      material: (_, __) => const MaterialApp(
        title: 'Mono Story',
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    );
  }
}
