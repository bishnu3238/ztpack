// HELPER CLASSES

import 'package:flutter/cupertino.dart';
 import 'match.dart';
import 'search_result_type.dart';

class SearchUtils {
  static TextSpan highlightMatchingText(String text, String query) {
    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = query.toLowerCase();

    if (!lowerCaseText.contains(lowerCaseQuery)) {
      return TextSpan(
        text: text,
        style: const TextStyle(color: CupertinoColors.black), // Default color for non-matching text
      );
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
      return TextSpan(
        text: text,
        style: const TextStyle(color: CupertinoColors.black),
      );
    }

    final spans = <TextSpan>[];
    int current = 0;
    for (final match in matches) {
      if (current < match.start) {
        spans.add(TextSpan(
          text: text.substring(current, match.start),
          style: const TextStyle(color: CupertinoColors.black), // Non-matching text color
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: CupertinoColors.activeBlue, // Matching text color
        ),
      ));
      current = match.end;
    }
    if (current < text.length) {
      spans.add(TextSpan(
        text: text.substring(current),
        style: const TextStyle(color: CupertinoColors.black),
      ));
    }

    return TextSpan(children: spans);
  }

  static String getGroupTitle(SearchResultType type) {
    switch (type) {
      case SearchResultType.category:
        return 'Categories';
      case SearchResultType.subCategory:
        return 'Subcategories';
      case SearchResultType.service:
        return 'Services';
      case SearchResultType.merchant:
        return 'Merchants';
      default:
        return 'Results';
    }
  }

  static Widget getIconForType(SearchResultType type) {
    IconData iconData;
    Color iconColor;
    switch (type) {
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
    return Icon(iconData, color: iconColor);
  }
}