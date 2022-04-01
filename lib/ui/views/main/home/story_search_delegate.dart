import 'package:flutter/material.dart';
import 'package:mono_story/ui/views/main/home/story_search_result_listview.dart';

class StorySearchDelegate extends SearchDelegate<String?> {
  StorySearchDelegate() : super(searchFieldLabel: 'Search Story');

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
          if (query.isEmpty) {
            close(context, null);
            return;
          }
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, query),
      icon: const Icon(Icons.arrow_back_ios_new),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const _SuggestionWidget();
    }
    return StorySearchResultListView(query: query.trim());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const _SuggestionWidget();
  }
}

class _SuggestionWidget extends StatelessWidget {
  const _SuggestionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search),
          Text(
            'Try searching for stories',
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  }
}
