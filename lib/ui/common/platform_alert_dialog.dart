import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'platform_widget_base.dart';

class PlatformAlertDialog extends PlatformWidgetBase {
  const PlatformAlertDialog({
    Key? key,
    required this.content,
  }) : super(key: key);

  final Widget content;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(content: content);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(content: content);
  }
}
