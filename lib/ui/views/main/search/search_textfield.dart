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
    // TODO - Clean up this textfield
    return TextField(
      style: const TextStyle(fontSize: 16),
      maxLines: 1,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.grey),
          onPressed: () => print('Cancel Icon pressed'),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 3),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      cursorColor: Colors.grey,
      keyboardType: TextInputType.name,
      controller: _searchController,
      onSubmitted: null,
      onChanged: (value) => print('onChanged: $value'),
    );
  }
}
