import 'package:flutter/material.dart';
import 'package:mono_story/ui/views/main/home/message_search_result_listview.dart';
import 'package:mono_story/view_models/message_viewmodel.dart';
import 'package:provider/src/provider.dart';

class MessageSearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.inputDecorationTheme.hintStyle,
        border: InputBorder.none,
      ),
    );
  }

  @override
  PreferredSizeWidget? buildBottom(BuildContext context) {
    return PreferredSize(
      child: Container(color: Colors.grey, height: 0.5),
      preferredSize: const Size.fromHeight(0.5),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, query);
      },
      icon: const Icon(Icons.arrow_back_ios_new),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return MessageSearchResultListView(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
