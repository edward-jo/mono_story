import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MonoAlertDialog {
  static void showNotifyAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String actionName,
    required void Function()? onPressed,
  }) {}

  static Future<T?> showProgressAlertDialog<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required String cancelActionName,
    required void Function() onCancelPressed,
  }) async {
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
            ],
          );
        },
      );
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
          ],
        );
      },
    );
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
