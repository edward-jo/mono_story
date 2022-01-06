import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'home/home_screen.dart';

class MainScreen extends StatefulWidget {
  static final routeName = '/main';
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const Center(child: Text('Search')),
    const Center(child: Text('Starred')),
  ];

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      //
      // CUPERTINO
      //
      cupertino: (_, __) => CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: mainBottomNavBarItems(),
        ),
        tabBuilder: (context, index) => CupertinoTabView(
          builder: (context) => _widgetOptions[index],
        ),
      ),

      //
      // MATERIAL
      //
      material: (_, __) => Scaffold(
        // BODY
        body: _widgetOptions[_selectedIndex],
        // BOTTOM NAVIGATION BAR
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: mainBottomNavBarItems(),
          onTap: (index) => setState(() {
            _selectedIndex = index;
          }),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> mainBottomNavBarItems() {
    return <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(PlatformIcons(context).home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(PlatformIcons(context).search),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        icon: Icon(PlatformIcons(context).star),
        label: 'Starred',
      ),
    ];
  }
}
