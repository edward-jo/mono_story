import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/fake_data.dart';

class NewThreadNameBottomSheet extends StatelessWidget {
  final void Function(String) onTap;
  const NewThreadNameBottomSheet({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        // -- BOTTOM SHEET HEAD --
        const SizedBox(height: 20),
        Text(
          'Select Thread',
          style: textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
