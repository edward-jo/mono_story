import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_widget_base.dart';

class PlatformAlertDialog extends PlatformWidgetBase {
  const PlatformAlertDialog({
    Key? key,
    required this.content,
    this.actions = const <Widget>[],
  }) : super(key: key);

  final Widget content;
  final List<Widget> actions;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(content: content, actions: actions);
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(content: content, actions: actions);
  }
}
