import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/thread.dart';
import 'package:mono_story/ui/common/mono_elevatedbutton.dart';
import 'package:mono_story/view_models/thread_viewmodel.dart';
import 'package:provider/provider.dart';

class RenameBottomSheet extends StatefulWidget {
  const RenameBottomSheet({Key? key, required this.threadName})
      : super(key: key);

  final String threadName;

  @override
  State<RenameBottomSheet> createState() => _RenameBottomSheetState();
}

class _RenameBottomSheetState extends State<RenameBottomSheet> {
  final _newThreadNameController = TextEditingController();
  late final ThreadViewModel _threadVM;
  final _bottomSheetPadding = const EdgeInsets.symmetric(horizontal: 25.0);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _threadVM = context.read<ThreadViewModel>();
    _newThreadNameController.text = widget.threadName;
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
        children: <Widget>[
          // -- BOTTOM SHEET HEAD --
          const SizedBox(height: 20),

          Text(
            'Rename Thread',
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
                    controller: _newThreadNameController,
                    validator: _validateNewThreadName,
                    onFieldSubmitted: (_) => _done(context),
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
    value = value?.trim();

    if (value == null || value.isEmpty) {
      return 'Thread name is required';
    } else if (value.characters.length > threadNameMaxCharLength) {
      developer.log(
        'Thread name validation:',
        error: jsonEncode('$value\'s length(${value.characters.length})'),
      );
      return 'Thread name should be with maximum of $threadNameMaxCharLength characters';
    } else if (_threadVM.findThreadData(name: value) != null) {
      return '$value already exists';
    }
    return null;
  }

  void _done(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final String name = _newThreadNameController.text.trim();

    if (name.isEmpty) return;

    Navigator.of(context).pop(name);
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
