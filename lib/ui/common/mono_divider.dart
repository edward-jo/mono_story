import 'package:flutter/material.dart';

class MonoDivider extends Divider {
  const MonoDivider({
    Key? key,
    double? height,
    double? thickness,
    double? indent,
    double? endIndent,
    Color? color,
  }) : super(
          key: key,
          height: height,
          thickness: thickness ?? 0.1,
          indent: indent,
          endIndent: endIndent,
          color: color ?? Colors.black,
        );
}
