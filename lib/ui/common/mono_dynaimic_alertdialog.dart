import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class _AlertDialogChildWidget extends StatefulWidget {
  const _AlertDialogChildWidget({Key? key, required this.child})
      : super(key: key);
  final Widget child;

  @override
  _AlertDialogChildWidgetState createState() => _AlertDialogChildWidgetState();
}

class _AlertDialogChildWidgetState extends State<_AlertDialogChildWidget> {
  late Widget _child;

  @override
  void initState() {
    super.initState();
    _child = widget.child;
  }

  @override
  Widget build(BuildContext context) {
    return _child;
  }

  void update(Widget child) {
    setState(() => _child = child);
  }
}

class MonoDynamicAlertDialog {
  final _titleKey = GlobalKey<_AlertDialogChildWidgetState>();
  final _contentKey = GlobalKey<_AlertDialogChildWidgetState>();
  final _cancelKey = GlobalKey<_AlertDialogChildWidgetState>();
  final _destructiveKey = GlobalKey<_AlertDialogChildWidgetState>();

  void Function()? _onCancelPressed;
  void Function()? _onDestructivePressed;

  void update({
    Widget? title,
    Widget? content,
    Widget? cancel,
    Widget? destructive,
    void Function()? onCancelPressed,
    void Function()? onDestructivePressed,
  }) {
    assert(!((cancel == null) ^ (onCancelPressed == null)));
    assert(!((destructive == null) ^ (onDestructivePressed == null)));

    if (title != null) _titleKey.currentState?.update(title);
    if (content != null) _contentKey.currentState?.update(content);
    if (cancel != null) _cancelKey.currentState?.update(cancel);
    if (destructive != null) _destructiveKey.currentState?.update(destructive);
    if (onCancelPressed != null) _onCancelPressed = onCancelPressed;
    if (onDestructivePressed != null) {
      _onDestructivePressed = onDestructivePressed;
    }
  }

  Future<T?> showNotifyAlertDialog<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    Widget? cancel,
    void Function()? onCancelPressed,
    Widget? destructive,
    void Function()? onDestructivePressed,
  }) async {
    assert(!((cancel == null) ^ (onCancelPressed == null)));
    assert(!((destructive == null) ^ (onDestructivePressed == null)));

    _onCancelPressed = onCancelPressed;
    _onDestructivePressed = onDestructivePressed;

    if (Platform.isIOS) {
      final actions = <CupertinoDialogAction>[];
      if (cancel != null && onCancelPressed != null) {
        actions.add(
          CupertinoDialogAction(
            isDefaultAction: true,
            child: _AlertDialogChildWidget(key: _cancelKey, child: cancel),
            onPressed: () => _onCancelPressed!(),
          ),
        );
      }
      if (destructive != null && onDestructivePressed != null) {
        actions.add(
          CupertinoDialogAction(
            isDefaultAction: true,
            child: _AlertDialogChildWidget(
              key: _destructiveKey,
              child: destructive,
            ),
            onPressed: () => _onDestructivePressed!(),
          ),
        );
      }

      return showCupertinoDialog<T>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: _AlertDialogChildWidget(key: _titleKey, child: title),
            content: _AlertDialogChildWidget(key: _contentKey, child: content),
            actions: actions,
          );
        },
      );
    } else {
      final actions = <Widget>[];
      if (cancel != null && onCancelPressed != null) {
        actions.add(
          GestureDetector(
            child: _AlertDialogChildWidget(key: _cancelKey, child: cancel),
            onTap: onCancelPressed,
          ),
        );
      }
      if (destructive != null && onDestructivePressed != null) {
        actions.add(
          GestureDetector(
            child: _AlertDialogChildWidget(
              key: _destructiveKey,
              child: destructive,
            ),
            onTap: onDestructivePressed,
          ),
        );
      }

      return showDialog<T>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: _AlertDialogChildWidget(key: _titleKey, child: title),
            content: _AlertDialogChildWidget(key: _contentKey, child: content),
            actions: actions,
          );
        },
      );
    }
  }
}
