import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MonoAlertDialog {
  /// To show the progress, use StatefulWidget as content and update progress
  /// status via GlobalKey<T extends StatefulWidget>.
  static Future<T?> showNotifyAlertDialog<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    String? cancelActionName,
    void Function()? onCancelPressed,
  }) async {
    assert(!((cancelActionName == null) ^ (onCancelPressed == null)));

    if (Platform.isIOS) {
      final actions = <CupertinoDialogAction>[];
      if (cancelActionName != null && onCancelPressed != null) {
        actions.add(
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(cancelActionName),
            onPressed: onCancelPressed,
          ),
        );
      }

      return showCupertinoDialog<T>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions,
          );
        },
      );
    } else {
      List<Widget>? actions;
      if (cancelActionName != null && onCancelPressed != null) {
        actions = <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(cancelActionName),
            onPressed: onCancelPressed,
          ),
        ];
      }

      return showDialog<T>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: title,
            content: content,
            actions: actions,
          );
        },
      );
    }
  }

  static Future<T?> showConfirmAlertDialog<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required String cancelActionName,
    required void Function() onCancelPressed,
    required String destructiveActionName,
    required void Function() onDestructivePressed,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog<T>(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: title,
              content: content,
              actions: <CupertinoDialogAction>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text(cancelActionName),
                  onPressed: onCancelPressed,
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text(destructiveActionName),
                  onPressed: onDestructivePressed,
                ),
              ],
            );
          });
    }

    return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title,
          content: content,
          actions: <Widget>[
            TextButton(
              child: Text(cancelActionName),
              onPressed: onCancelPressed,
            ),
            TextButton(
              child: Text(destructiveActionName),
              onPressed: onDestructivePressed,
            ),
          ],
        );
      },
    );
  }
}
