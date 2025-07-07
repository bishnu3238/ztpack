import '../../../../failure/failure.dart';

/// Network or storage error representation
class SearchFailure extends Failure {
  final Exception? exception;

  const SearchFailure({String? code, required super.message, this.exception})
    : super(code: code ?? 'SEARCH_FAILURE');
}
