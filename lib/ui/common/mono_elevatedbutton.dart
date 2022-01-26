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
      width: MediaQuery.of(context).size.width * 0.7,
      height: 30.0,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
