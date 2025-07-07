import 'package:flutter/cupertino.dart';
 import 'package:provider/provider.dart';
import '../core/models/search_failure.dart';
import '../state/search_view_model.dart';

class SearchErrorView extends StatelessWidget {
  const SearchErrorView({
    super.key,
     required this.failure,
  });

   final SearchFailure failure;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 48,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(height: 16),
          Text(
            failure.message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            child: const Text('Retry'),
            onPressed: () {
              final viewModel = Provider.of<SearchProvider>(
                context,
                listen: false,
              );
              viewModel.search();
            },
          ),
        ],
      ),
    );
  }
}
