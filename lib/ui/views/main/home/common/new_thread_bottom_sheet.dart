import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:provider/provider.dart';

class NewThreadBottomSheet extends StatefulWidget {
  const NewThreadBottomSheet({Key? key}) : super(key: key);

  @override
  State<NewThreadBottomSheet> createState() => _NewThreadBottomSheetState();
}

class _NewThreadBottomSheetState extends State<NewThreadBottomSheet> {
  final _newThreadNameController = TextEditingController();
  late final MessageViewModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<MessageViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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

                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _done(BuildContext context) async {
    final String name = _newThreadNameController.text.trim();

    if (name.isEmpty) return;

    developer.log('New thread name( $name )');
    Thread t = await _model.createThreadName(Thread(id: null, name: name));

    Navigator.of(context).pop(t.id);
  }
}
