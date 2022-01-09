import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/constants.dart';

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
