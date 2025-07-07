import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../core/models/search_result_type.dart';
import '../core/models/search_utils.dart';
import '../core/models/searchable.dart';
import '../state/search_view_model.dart';
import 'search_page.dart';
import 'search_result_item.dart';
class SearchResultList extends StatelessWidget {
  const SearchResultList({
    super.key,
    required ScrollController scrollController,
    required this.widget,
    required this.results,
    required this.viewModel,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final SearchPage widget;
  final List<Searchable> results;
  final SearchProvider viewModel;

  @override
  Widget build(BuildContext context) {
    final groupedResults = <SearchResultType, List<Searchable>>{};
    for (final result in results) {
      groupedResults.putIfAbsent(result.resultType, () => []).add(result);
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: groupedResults.length + (viewModel.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == groupedResults.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
        final entry = groupedResults.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                SearchUtils.getGroupTitle(entry.key),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...entry.value.map(
                  (result) => SearchResultItem(
                result: result,
                onTap:
                    () => widget.onResultTap(result), // Use external callback
                query: viewModel.query,
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
