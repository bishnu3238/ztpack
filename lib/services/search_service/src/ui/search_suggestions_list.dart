import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/models/search_result_type.dart';
import '../core/models/search_utils.dart';
import '../core/models/searchable.dart';
import '../state/search_view_model.dart';

class SearchSuggestionsList extends StatelessWidget {
  const SearchSuggestionsList({
    super.key,
    required TextEditingController searchController,
    required this.viewModel,
  }) : _searchController = searchController;

  final TextEditingController _searchController;
  final SearchProvider viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No suggestions found'),
      );
    }

    final groupedSuggestions = <SearchResultType, List<Searchable>>{};
    for (final suggestion in viewModel.suggestions) {
      groupedSuggestions
          .putIfAbsent(suggestion.resultType, () => [])
          .add(suggestion);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: groupedSuggestions.length,
      itemBuilder: (context, index) {
        final entry = groupedSuggestions.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                SearchUtils.getGroupTitle(entry.key),
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            ...entry.value.map(
                  (suggestion) => ListTile(
                leading: SearchUtils.getIconForType(suggestion.resultType),
                title: RichText(
                  text: SearchUtils.highlightMatchingText(
                    suggestion.displayName,
                    viewModel.query,
                  ),
                ),
                subtitle:
                suggestion.displayDescription.isNotEmpty
                    ? Text(
                  suggestion.displayDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                    : null,
                onTap: () {
                  _searchController.text = suggestion.displayName;
                  viewModel.onQueryChanged(suggestion.displayName);
                  viewModel.search();
                },
              ),
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
