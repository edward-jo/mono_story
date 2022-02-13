import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/ui/common/platform_widget_base.dart';

class PlatformRefreshIndicator extends PlatformWidgetBase {
  const PlatformRefreshIndicator({
    Key? key,
    this.listKey,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
  }) : super(key: key);

  final Future<void> Function() onRefresh;
  final ScrollController? controller;
  final int itemCount;
  final Widget Function(BuildContext, int, Animation<double>) itemBuilder;
  final Key? listKey;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: controller,
      slivers: <Widget>[
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
        ),
        SliverAnimatedList(
          key: listKey,
          initialItemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      ],
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.black,
      child: AnimatedList(
        key: listKey,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller,
        initialItemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
