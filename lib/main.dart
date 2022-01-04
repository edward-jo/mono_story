import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PlatformApp(
      debugShowCheckedModeBanner: false,
      title: 'title',
      // material: (_, __) => MaterialAppData(
      //   theme: ThemeData(primarySwatch: Colors.blue),
      // ),
      // cupertino: (_, __) => CupertinoAppData(),
      home: MyHomePage(title: 'title'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    String appBarTitleImg;
    if (Platform.isIOS) {
      appBarTitleImg = 'appbar_title_blue.png';
    } else {
      appBarTitleImg = 'appbar_title_white.png';
    }

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Image.asset(
          'assets/images/$appBarTitleImg',
          width: 64,
          height: 64,
        ),
      ),
      body: const Center(child: Text('MyHomePage')),
    );
  }
}
