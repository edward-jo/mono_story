import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MonoAlertDialog {
  static void showAlertNotifyDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String actionName,
    required void Function()? onPressed,
  }) {}

  static Future<T?> showAlertConfirmDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
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
              title: Text(title),
              content: Text(content),
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
          title: Text(title),
          content: Text(content),
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