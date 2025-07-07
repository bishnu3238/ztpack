import 'search_result_type.dart';

/// Base searchable model interface
abstract class Searchable {
  String get id;
  String get displayName;
  String get displayDescription;
  String? get imageUrl;
  SearchResultType get resultType;

  Map<String, dynamic> get searchableFields;

  bool matchesQuery(String query) {
    final lowercaseQuery = query.toLowerCase();
    return searchableFields.values.any((value) {
      if (value is String) {
        return value.toLowerCase().contains(lowercaseQuery);
      } else if (value is num) {
        return value.toString().contains(lowercaseQuery);
      }
      return false;
    });
  }

  @override
  String toString() {
    return 'Searchable{ $id, $displayName, $displayDescription, $imageUrl, $searchableFields}';
  }
}
