import 'package:flutter/material.dart';
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
        body: const Center(
          child: Text('Search Screen'),
        ),
      ),
    );
  }
}
