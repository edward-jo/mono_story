import 'package:flutter/material.dart';
import 'package:mono_story/ui/views/main/home/new_message/new_message_screen.dart';
import 'package:mono_story/ui/views/main/search/search_textfield.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const SearchTextField(),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(
              NewMessageScreen.routeName,
            ),
            child: const Text('Search Screen'),
          ),
        ),
      ),
    );
  }
}
