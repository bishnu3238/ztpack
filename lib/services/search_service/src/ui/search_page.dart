import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/models/searchable.dart';
import '../state/search_view_model.dart';
import 'recent_searches.dart';
import 'search_empty_view.dart';
import 'search_error_view.dart';
import 'search_navigation_bar.dart';
import 'search_result_list.dart';
import 'search_suggestions_list.dart';

class SearchPage extends StatefulWidget {
  final Widget recommendedSuggestions; // Custom widget for recommendations
  final void Function(Searchable) onResultTap; // Callback for result tap

  const SearchPage({
    super.key,
    required this.recommendedSuggestions,
    required this.onResultTap,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Listen to focus changes
    _searchFocusNode.addListener(() {
      final viewModel = Provider.of<SearchProvider>(context, listen: false);
      viewModel.setFocus(_searchFocusNode.hasFocus);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<SearchProvider>(context, listen: false).loadMoreResults();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: SearchNavBar(
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
      ),
      child: Material(
        child: Consumer<SearchProvider>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    children: [
                      _buildMainContent(viewModel),
                      if (viewModel.showSuggestions)
                        _buildSuggestionsOverlay(viewModel),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(SearchProvider viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (viewModel.query.isEmpty) {
      // Show recommended suggestions when not focused, recent searches when focused
      return viewModel.isFocused
          ? RecentSearches(
            searchController: _searchController,
            viewModel: viewModel,
          )
          : widget.recommendedSuggestions;
    }

    return viewModel.searchResult.fold(
      (failure) => SearchErrorView(failure: failure),
      (results) =>
          results.isEmpty
              ? SearchEmptyView()
              : SearchResultList(
                scrollController: _scrollController,
                widget: widget,
                results: results,
                viewModel: viewModel,
              ),
    );
  }

  Widget _buildSuggestionsOverlay(SearchProvider viewModel) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: SearchSuggestionsList(
          searchController: _searchController,
          viewModel: viewModel,
        ),
      ),
    );
  }
}
