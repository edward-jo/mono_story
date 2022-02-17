import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mono_story/ui/common/platform_widget_base.dart';

class PlatformSwitch extends PlatformWidgetBase {
  const PlatformSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
    );
  }
}
