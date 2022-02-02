import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/mono_elevatedbutton.dart';
import 'package:mono_story/ui/common/platform_alert_dialog.dart';
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
  final _bottomSheetPadding = const EdgeInsets.symmetric(horizontal: 25.0);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _model = context.read<MessageViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final inputDecorationTheme = Theme.of(context).inputDecorationTheme;
    var inputDecoration = const InputDecoration(hintText: 'Thread name');
    inputDecoration = inputDecoration.applyDefaults(inputDecorationTheme);

    return Container(
      padding: _bottomSheetPadding,
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

          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                // -- THREAD NAME TEXT FILED --
                Form(
                  key: _formKey,
                  child: TextFormField(
                    maxLines: 1,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    decoration: inputDecoration,
                    keyboardAppearance: Brightness.light,
                    controller: _newThreadNameController,
                    validator: _validateNewThreadName,
                  ),
                ),

                const SizedBox(height: 10.0),

                // -- DONE BUTTON --
                MonoElevatedButton(
                  onPressed: () => _done(context),
                  child: const Text('Done'),
                ),

                // -- CANCEL BUTTON --
                TextButton(
                  onPressed: () => _cancel(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _validateNewThreadName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Thread name is required';
    } else if (value.length > threadNameMaxLength) {
      return 'Thread name should be with maximum of $threadNameMaxLength characters';
    } else if (_model.findThreadData(name: value) != null) {
      return '$value already exists';
    }
    return null;
  }

  void _done(BuildContext context) async {
    developer.log('_done');

    if (!_formKey.currentState!.validate()) return;

    final String name = _newThreadNameController.text.trim();

    if (name.isEmpty) return;

    developer.log('New thread name( $name )');
    Thread t = await _model.createThreadName(Thread(id: null, name: name));

    Navigator.of(context).pop(t.id);
  }

  void _cancel(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class LowerCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}
