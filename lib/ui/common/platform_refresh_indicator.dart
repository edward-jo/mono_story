import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/ui/common/platform_widget_base.dart';

class PlatformRefreshIndicator extends PlatformWidgetBase {
  const PlatformRefreshIndicator({
    Key? key,
    required this.onRefresh,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
  }) : super(key: key);

  final Future<void> Function() onRefresh;
  final ScrollController? controller;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: controller,
      slivers: <Widget>[
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
          ),
        ),
      ],
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.black,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
