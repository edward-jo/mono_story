import 'package:flutter/material.dart';

class StyledPopupMenuItem<T> extends PopupMenuItem<T> {
  StyledPopupMenuItem({
    Key? key,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    required this.menuName,
    required this.icon,
    required T value,
  }) : super(
          key: key,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          value: value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: Text(menuName, softWrap: true),
              ),
              icon,
            ],
          ),
        );

  final String menuName;
  final Icon icon;
  final double maxWidth;
  final double maxHeight;
}
