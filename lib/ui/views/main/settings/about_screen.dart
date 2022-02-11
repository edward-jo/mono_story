import 'package:flutter/material.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/ui/common/platform_indicator.dart';
import 'package:mono_story/ui/common/styled_builder_error_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  static const String routeName = '/settings/about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('About'),
      ),
      body: FutureBuilder<PackageInfo>(
        future: getPackageInfoFuture(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: PlatformIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return StyledBuilderErrorWidget(
              message: snapshot.error.toString(),
            );
          }

          PackageInfo packageInfo = snapshot.data as PackageInfo;

          return Column(
            children: <Widget>[
              // LICENSES
              ListTile(
                title: const Text('Licenses'),
                trailing: Icon(MonoIcons.chevron_forward, size: 20.0),
                onTap: () => showLicensePage(context: context),
              ),

              // VERSION
              ListTile(
                title: const Text('Version'),
                trailing: Text(
                  packageInfo.version,
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<PackageInfo> getPackageInfoFuture() async {
    return await PackageInfo.fromPlatform();
  }
}
