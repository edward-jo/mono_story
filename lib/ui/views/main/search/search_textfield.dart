import 'dart:developer' as developer;
import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  const SearchTextField({Key? key}) : super(key: key);

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      maxLines: 1,
      style: textTheme.bodyText2,
      keyboardType: TextInputType.name,
      keyboardAppearance: Brightness.light,
      controller: _searchController,
      onSubmitted: (value) => developer.log('Submitted: $value'),
      onChanged: (value) => developer.log('onChanged: $value'),

      // -- DECORATION --
      decoration: InputDecoration(
        // -- COLOR --
        filled: true,
        fillColor: Colors.grey.shade200,

        // -- SEARCH HINT --
        hintText: 'Search',
        hintStyle: textTheme.bodyText2?.copyWith(color: Colors.grey),

        // -- SEARCH ICON --
        prefixIcon: const Icon(Icons.search, color: Colors.grey),

        // -- CANCEL ICON BUTTON --
        suffixIcon: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.grey),
          onPressed: () => _searchController.clear(),
        ),

        // -- PADDING --
        contentPadding: const EdgeInsets.symmetric(vertical: 3),

        // -- OUTLINE INPUT BORDER --
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
