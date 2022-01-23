import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:mono_story/fake_data.dart';

class NewThreadNameBottomSheet extends StatefulWidget {
  const NewThreadNameBottomSheet({Key? key}) : super(key: key);

  @override
  State<NewThreadNameBottomSheet> createState() =>
      _NewThreadNameBottomSheetState();
}

class _NewThreadNameBottomSheetState extends State<NewThreadNameBottomSheet> {
  final _newThreadNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // -- BOTTOM SHEET HEAD --
          const SizedBox(height: 20),
          Text(
            'Create New Thread',
            style: textTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // -- THREAD NAME TEXT FILED --
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                TextField(
                  autofocus: true,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  keyboardAppearance: Brightness.light,
                  controller: _newThreadNameController,
                ),
                const SizedBox(height: 10.0),

                // -- DONE BUTTON --
                TextButton(
                  onPressed: () => _done(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _done(BuildContext context) {
    final String name = _newThreadNameController.text.trim();

    if (name.isEmpty) return;

    developer.log('New thread name( $name )');
    // TODO: insert new thread name to database

    Navigator.of(context).pop(name);
  }
}
