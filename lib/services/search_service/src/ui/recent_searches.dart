import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../state/search_view_model.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    super.key,
    required TextEditingController searchController,
    required this.viewModel,
  }) : _searchController = searchController;

  final TextEditingController _searchController;
  final SearchProvider viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.recentSearches.isEmpty) {
      return const Center(child: Text('No recent searches'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Clear All'),
                onPressed: () {
                  viewModel.clearRecentSearches();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.recentSearches.length,
            itemBuilder: (context, index) {
              final search = viewModel.recentSearches[index];
              return ListTile(
                leading: const Icon(CupertinoIcons.clock),
                title: Text(search),
                onTap: () {
                  _searchController.text = search;
                  viewModel.useRecentSearch(search);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
