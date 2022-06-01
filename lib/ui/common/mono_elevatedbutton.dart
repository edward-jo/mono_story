import 'package:flutter/material.dart';

class MonoElevatedButton extends StatelessWidget {
  const MonoElevatedButton({
    Key? key,
    required this.child,
    required this.onPressed,
  }) : super(key: key);

  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40.0,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
