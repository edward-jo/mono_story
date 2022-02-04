import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/ui/common/platform_widget.dart';
import 'package:mono_story/ui/views/main/home/home_screen.dart';

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
    const Center(child: Text('Starred')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BODY
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: mainBottomNavBarItems(),
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
      ),
    );
  }

  List<BottomNavigationBarItem> mainBottomNavBarItems() {
    return const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: PlatformWidget(
          cupertino: Icon(CupertinoIcons.home),
          material: Icon(Icons.home),
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: PlatformWidget(
          cupertino: Icon(CupertinoIcons.star),
          material: Icon(Icons.star),
        ),
        label: 'Star',
      ),
    ];
  }
}
