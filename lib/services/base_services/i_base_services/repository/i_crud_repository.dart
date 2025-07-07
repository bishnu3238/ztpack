import 'i_repository.dart';

/// Example of a generic repository interface for CRUD operations
abstract class ICrudRepository<T> implements IRepository {
  Future<List<T>> getAll({Map<String, dynamic>? params});
  Future<T?> getById(dynamic id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<bool> delete(dynamic id);
}

/// Example of a searchable repository
abstract class ISearchableRepository<T> implements ICrudRepository<T> {
  Future<List<T>> search(String query, {Map<String, dynamic>? params});
}
