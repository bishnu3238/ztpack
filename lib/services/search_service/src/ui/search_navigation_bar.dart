import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/search_view_model.dart';

class SearchNavBar extends StatelessWidget implements ObstructingPreferredSizeWidget{
  const SearchNavBar({
    super.key,
    required TextEditingController searchController,
    required FocusNode searchFocusNode,
  }) : _searchController = searchController, _searchFocusNode = searchFocusNode;

  final TextEditingController _searchController;
  final FocusNode _searchFocusNode;

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      middle: Consumer<SearchProvider>(
        builder: (context, viewModel, _) {
          return CupertinoSearchTextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            placeholder: 'Search',
            onChanged: (value) {
              viewModel.onQueryChanged(value);
            },
            onSubmitted: (_) {
              viewModel.search();
            },
            prefixInsets: const EdgeInsetsDirectional.fromSTEB(6, 0, 0, 4),
            suffixInsets: const EdgeInsetsDirectional.fromSTEB(0, 0, 5, 2),
            suffixMode: OverlayVisibilityMode.editing,
            suffixIcon:  Icon(Icons.mic_none),onSuffixTap: (){},
          );
        },
      ),
      trailing: Consumer<SearchProvider>(
        builder: (context, viewModel, _) {
          return CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text('Cancel'),
            onPressed: () {
              viewModel.clearSearch();
              _searchController.clear();
            },
          );
        },
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kBottomNavigationBarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    // TODO: implement shouldFullyObstruct
    return true; // Return true if the navigation bar fully obstructs the content.
    throw UnimplementedError();
  }
}
