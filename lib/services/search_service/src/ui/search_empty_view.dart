import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/search_view_model.dart';

class SearchEmptyView extends StatelessWidget {
  const SearchEmptyView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          Consumer<SearchProvider>(
            builder: (context, viewModel, _) {
              return Text(
                'No results found for "${viewModel.query}"',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              );
            },
          ),
        ],
      ),
    );
  }
}
