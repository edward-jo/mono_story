import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: PlatformScaffold(
        // APP BAR
        appBar: PlatformAppBar(
          title: PlatformWidget(
            cupertino: cupertinoImageAsset,
            material: materialImageAsset,
          ),
          material: materialAppBarData,
        ),
        // body: const Center(child: Text('Home Page')),
        body: const TabBarView(
          children: [
            Center(child: Text('tab1 page')),
            Center(child: Text('tab2 page')),
            Center(child: Text('tab3 page')),
            Center(child: Text('tab4 page')),
            Center(child: Text('tab5 page')),
          ],
        ),
      ),
    );
  }

  Widget? cupertinoImageAsset(BuildContext context, PlatformTarget target) {
    String assetName = 'assets/images/appbar_title_blue.png';
    return Image.asset(assetName, width: 64, height: 64);
  }

  Widget? materialImageAsset(BuildContext context, PlatformTarget target) {
    String assetName = 'assets/images/appbar_title_white.png';
    return Image.asset(assetName, width: 64, height: 64);
  }

  CupertinoNavigationBarData cupertinoNavigationBarData(
    BuildContext context,
    PlatformTarget target,
  ) {
    return CupertinoNavigationBarData();
  }

  MaterialAppBarData materialAppBarData(
    BuildContext context,
    PlatformTarget target,
  ) {
    return MaterialAppBarData(
      bottom: const TabBar(tabs: [
        Tab(child: Text('tab1')),
        Tab(child: Text('tab2')),
        Tab(child: Text('tab3')),
        Tab(child: Text('tab4')),
        Tab(child: Text('tab5')),
      ]),
    );
  }
}
