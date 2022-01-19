import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_widget_base.dart';

class PlatformIndicator extends PlatformWidgetBase {
  const PlatformIndicator({Key? key}) : super(key: key);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return const CupertinoActivityIndicator();
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
