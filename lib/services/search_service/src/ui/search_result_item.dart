import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/models/match.dart';
import '../core/models/search_result_type.dart';
import '../core/models/searchable.dart';

/// Individual search result item widget
class SearchResultItem extends StatelessWidget {
  final Searchable result;
  final VoidCallback onTap;
  final String query;

  const SearchResultItem({
    super.key,
    required this.result,
    required this.onTap,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image or icon
              if (result.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    result.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackIcon();
                    },
                  ),
                )
              else
                _buildFallbackIcon(),

              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: _highlightMatchingText(result.displayName, query),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (result.displayDescription.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      RichText(
                        text: _highlightMatchingText(
                          result.displayDescription,
                          query,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        // style: const TextStyle(
                        //   fontSize: 14,
                        //   color: CupertinoColors.systemGrey,
                        // ),
                      ),
                    ],
                  ],
                ),
              ),

              // Navigation chevron
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    IconData iconData;
    Color iconColor;

    switch (result.resultType) {
      case SearchResultType.category:
        iconData = CupertinoIcons.folder;
        iconColor = CupertinoColors.activeBlue;
        break;
      case SearchResultType.subCategory:
        iconData = CupertinoIcons.folder_fill;
        iconColor = CupertinoColors.activeOrange;
        break;
      case SearchResultType.service:
        iconData = CupertinoIcons.tag;
        iconColor = CupertinoColors.activeGreen;
        break;
      case SearchResultType.merchant:
        iconData = CupertinoIcons.person;
        iconColor = CupertinoColors.systemPurple;
        break;
      default:
        iconData = CupertinoIcons.search;
        iconColor = CupertinoColors.systemGrey;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 30),
    );
  }

  TextSpan _highlightMatchingText(String text, String query) {
    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();

    if (!lowerCaseText.contains(lowerCaseQuery)) {
      return TextSpan(text: text, style: TextStyle(color: Colors.grey));
    }

    final matches = <Match>[];
    int start = 0;
    while (true) {
      final index = lowerCaseText.indexOf(lowerCaseQuery, start);
      if (index == -1) break;
      matches.add(Match(index, index + lowerCaseQuery.length));
      start = index + 1;
    }

    if (matches.isEmpty) {
      return TextSpan(text: text, style: TextStyle(color: Colors.red));
    }

    final spans = <TextSpan>[];
    int current = 0;

    for (final match in matches) {
      if (current < match.start) {
        spans.add(
          TextSpan(
            text: text.substring(current, match.start),
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: CupertinoColors.activeBlue,
          ),
        ),
      );
      current = match.end;
    }

    if (current < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(current),
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return TextSpan(children: spans, style: TextStyle(color: Colors.grey));
  }
}
