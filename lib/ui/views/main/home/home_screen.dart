import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/ui/common/platform_widget.dart';
import 'home_screen_cupertino.dart';
import 'home_screen_material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const PlatformWidget(
      cupertino: HomeScreenCupertino(),
      material: HomeScreenMaterial(),
    );
  }
}
