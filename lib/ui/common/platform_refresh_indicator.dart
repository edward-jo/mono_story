import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/ui/common/platform_widget_base.dart';

class PlatfomRefreshIndicator extends PlatformWidgetBase {
  const PlatfomRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
        ),
        SliverToBoxAdapter(child: child),
      ],
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return RefreshIndicator(
      child: child,
      onRefresh: onRefresh,
      color: Colors.black,
    );
  }
}
