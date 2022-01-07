import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';

import '/ui/common/platform_widget.dart';

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

class HomeScreenCupertino extends StatefulWidget {
  const HomeScreenCupertino({Key? key}) : super(key: key);

  @override
  _HomeScreenCupertinoState createState() => _HomeScreenCupertinoState();
}

class _HomeScreenCupertinoState extends State<HomeScreenCupertino> {
  int _currentIndex = 0;
  final items = <Widget>[
    const Center(child: Text('tab1 page')),
    const Center(child: Text('tab2 page')),
    const Center(child: Text('tab3 page')),
    const Center(child: Text('tab4 page')),
    const Center(child: Text('tab5 page')),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Image.asset(homeScreenTitleImgC, width: 64, height: 64),
        trailing: CupertinoButton(
          child: const Icon(CupertinoIcons.add),
          onPressed: () {},
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            CupertinoTabView(
              builder: (context) => items[_currentIndex],
            ),
            Container(
              alignment: Alignment.bottomRight,
              child: CupertinoButton(
                child: const Text('BUTTON'),
                onPressed: () => setState(() {
                  _currentIndex = (_currentIndex >= 4) ? 0 : _currentIndex + 1;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreenMaterial extends StatefulWidget {
  const HomeScreenMaterial({Key? key}) : super(key: key);

  @override
  _HomeScreenMaterialState createState() => _HomeScreenMaterialState();
}

class _HomeScreenMaterialState extends State<HomeScreenMaterial> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
          // APP BAR
          appBar: AppBar(
            title: Image.asset(homeScreenTitleImgM, width: 32, height: 32),
            centerTitle: true,
            actions: <Widget>[
              IconButton(onPressed: () {}, icon: const Icon(Icons.add_outlined))
            ],
          ),
          body: const SafeArea(
            child: TabBarView(
              children: [
                Center(child: Text('tab1 page')),
                Center(child: Text('tab2 page')),
                Center(child: Text('tab3 page')),
                Center(child: Text('tab4 page')),
                Center(child: Text('tab5 page')),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'New message',
            child: const Icon(Icons.add),
            onPressed: () {},
          )),
    );
  }
}
