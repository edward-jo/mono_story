import 'package:flutter/material.dart';
import 'package:mono_story/ui/common/platform_widget_base.dart';

class PlatformWidget extends PlatformWidgetBase {
  final Widget cupertino;
  final Widget material;

  const PlatformWidget({
    Key? key,
    required this.cupertino,
    required this.material,
  }) : super(key: key);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return cupertino;
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return material;
  }
}
