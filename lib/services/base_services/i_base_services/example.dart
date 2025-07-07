import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:pack/services/base_services/base_model.dart';
import 'package:pack/services/failure/failure.dart';
import 'i_base_services.dart';

/// Example of a model integration
class User extends BaseModel<User> {
  final String name;
  final String email;
  final String? profileUrl;

  const User({
    required super.id,
    required this.name,
    required this.email,
    this.profileUrl,
  });

  @override
  User copyWith() {
    throw UnimplementedError();
  }

  User fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  static const User _empty = User(id: '', name: '', email: '');

  User empty() => User._empty;
}

class UserPreferences extends IBaseModel {
  final bool darkMode;
  final String language;
  final Map<String, dynamic> settings;

  const UserPreferences({
    this.darkMode = false,
    this.language = 'en',
    this.settings = const {},
    super.id,
  });

  @override
  String get id => throw UnimplementedError();

  @override
  List<Object?> get props => throw UnimplementedError();

  static final UserPreferences _empty = UserPreferences(darkMode: false);

  UserPreferences empty() => UserPreferences._empty;
}

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final String? token;
  final DateTime? tokenExpiry;
  final UserPreferences preferences;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.token,
    this.tokenExpiry,
    this.preferences = const UserPreferences(),
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    String? token,
    DateTime? tokenExpiry,
    UserPreferences? preferences,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      token: token ?? this.token,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      preferences: preferences ?? this.preferences,
    );
  }
}

/// Example auth data store using EntityStore
class AuthStore extends EntityStore<AuthState> {
  AuthStore() : super(initialEntity: const AuthState());

  void setAuthenticated(User user, String token, {DateTime? expiry}) {
    setEntity(
      AuthState(
        isAuthenticated: true,
        user: user,
        token: token,
        tokenExpiry: expiry ?? DateTime.now().add(const Duration(hours: 1)),
      ),
    );
  }

  void updateUser(User user) {
    updateEntity(
      (current) =>
          current?.copyWith(user: user) ??
          AuthState(isAuthenticated: true, user: user),
    );
  }

  void updatePreferences(UserPreferences preferences) {
    updateEntity((current) => current!.copyWith(preferences: preferences));
  }

  void logout() {
    setEntity(const AuthState());
  }

  bool get isLoggedIn =>
      entity?.isAuthenticated == true && entity?.user != null;

  bool get isTokenExpired {
    final expiry = entity?.tokenExpiry;
    return expiry == null || DateTime.now().isAfter(expiry);
  }
}

/// Example auth repository implementation
class AuthRepository implements IAuthRepository<User> {
  @override
  String get repositoryName => 'auth';

  @override
  Future<Either<AuthFailure, User>> login(LoginRequest request) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return right(User(id: '1', name: 'Test User', email: request.username));
  }

  @override
  Future<bool> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
    // API call to invalidate token
  }

  @override
  Future<Either<AuthFailure, User>> register(RegisterRequest request) async {
    await Future.delayed(const Duration(seconds: 1));
    return right(User(id: '1', name: request.username, email: request.email));
  }

  @override
  Future<User> getUserProfile([String? userId]) async {
    await Future.delayed(const Duration(seconds: 1));
    return User(id: '1', name: 'Test User', email: 'test@example.com');
  }

  @override
  Future<Either<AuthFailure, User>> changePassword(
    ChangePasswordRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, User>> forgotPassword(
    ForgotPasswordRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<R> getUserPreferences<R extends IBaseModel>([String? userId]) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, User>> resendOTP(ResendOTPRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, User>> resetPassword(
    ResetPasswordRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<R> updateUserPreferences<R extends IBaseModel>(R preferences) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, User>> verifyEmail(VerifyEmailRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AuthFailure, User>> verifyOTP(VerifyOTPRequest request) {
    throw UnimplementedError();
  }
}

class AppLoginRequest extends LoginRequest {
  AppLoginRequest({required super.username, required super.password});
}

/// Example service that coordinates repository and stores
class AuthService {
  final AuthStore _authStore;
  final IAuthRepository<User> _authRepository;

  AuthService({
    required AuthStore authStore,
    required IAuthRepository<User> authRepository,
  }) : _authStore = authStore,
       _authRepository = authRepository;

  Future<bool> login(String username, String password) async {
    try {
      _authStore.setStatus(DataStoreStatus.loading);

      final value = await _authRepository.login(
        AppLoginRequest(password: '', username: ''),
      );
      final preferences =
          await _authRepository.getUserPreferences<UserPreferences>();

      _authStore.setEntity(
        AuthState(
          isAuthenticated: true,
          user: value.getRight(),
          token: '',
          tokenExpiry: DateTime.now().add(const Duration(hours: 1)),
          preferences: preferences,
        ),
      );

      return true;
    } catch (e, stackTrace) {
      _authStore.setError(
        OperationFailure(
          message: 'Login failed',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _authStore.setStatus(DataStoreStatus.updating);
      await _authRepository.logout();
      _authStore.logout();
    } catch (e, stackTrace) {
      _authStore.setError(
        OperationFailure(
          message: 'Logout failed',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      _authStore.setStatus(DataStoreStatus.updating);
      final updated = await _authRepository
          .updateUserPreferences<UserPreferences>(preferences);
      _authStore.updatePreferences(updated);
    } catch (e, stackTrace) {
      _authStore.setError(
        OperationFailure(
          message: 'Failed to update preferences',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

/// Example of a multi-entity store
class DashboardStore extends ChangeNotifier implements IDataStore {
  final CollectionStore<Post> _postsStore = PostsStore();
  final CollectionStore<Category> _categoriesStore = CategoriesStore();
  final EntityStore<UserStats> _statsStore = UserStatsStore();

  DataStoreStatus _status = DataStoreStatus.initial;
  OperationFailure? _error;

  // Expose child stores
  CollectionStore<Post> get postsStore => _postsStore;
  CollectionStore<Category> get categoriesStore => _categoriesStore;
  EntityStore<UserStats> get statsStore => _statsStore;

  // Implement IDataStore
  @override
  DataStoreStatus get status => _status;

  @override
  OperationFailure? get error => _error;

  @override
  bool get isInitial => _status == DataStoreStatus.initial;

  @override
  bool get isLoading =>
      _status == DataStoreStatus.loading ||
      _postsStore.isLoading ||
      _categoriesStore.isLoading ||
      _statsStore.isLoading;

  @override
  bool get isError =>
      _error != null ||
      _postsStore.isError ||
      _categoriesStore.isError ||
      _statsStore.isError;

  @override
  bool get isLoaded => _status == DataStoreStatus.loaded;

  @override
  bool get isRefreshing => _status == DataStoreStatus.refreshing;

  @override
  bool get isUpdating => _status == DataStoreStatus.updating;

  // Constructor sets up listeners
  DashboardStore() {
    _postsStore.addListener(_onChildStoreChanged);
    _categoriesStore.addListener(_onChildStoreChanged);
    _statsStore.addListener(_onChildStoreChanged);
  }

  void _onChildStoreChanged() {
    // Propagate error states from child stores
    final childWithError = [
      _postsStore,
      _categoriesStore,
      _statsStore,
    ].firstWhere((store) => store.isError, orElse: () => _postsStore);

    if (childWithError.error != null) {
      _error = childWithError.error;
      _status = DataStoreStatus.error;
    } else if ([
      _postsStore,
      _categoriesStore,
      _statsStore,
    ].any((s) => s.isLoading)) {
      _status = DataStoreStatus.loading;
      _error = null;
    } else if ([
      _postsStore,
      _categoriesStore,
      _statsStore,
    ].every((s) => s.isLoaded)) {
      _status = DataStoreStatus.loaded;
      _error = null;
    }

    notifyListeners();
  }

  @override
  void setStatus(DataStoreStatus status) {
    if (_status != status) {
      _status = status;
      notifyListeners();
    }
  }

  @override
  void setError(OperationFailure failure) {
    _error = failure;
    setStatus(DataStoreStatus.error);
  }

  @override
  void clearError() {
    _error = null;
    _postsStore.clearError();
    _categoriesStore.clearError();
    _statsStore.clearError();

    // Update status based on child stores
    if ([_postsStore, _categoriesStore, _statsStore].every((s) => s.isLoaded)) {
      setStatus(DataStoreStatus.loaded);
    } else {
      setStatus(DataStoreStatus.initial);
    }
  }

  @override
  void reset() {
    _postsStore.reset();
    _categoriesStore.reset();
    _statsStore.reset();
    _error = null;
    setStatus(DataStoreStatus.initial);
  }

  @override
  void dispose() {
    _postsStore.removeListener(_onChildStoreChanged);
    _categoriesStore.removeListener(_onChildStoreChanged);
    _statsStore.removeListener(_onChildStoreChanged);
    _postsStore.dispose();
    _categoriesStore.dispose();
    _statsStore.dispose();
    super.dispose();
  }
}

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

/// Multiple-store coordinator to update related stores
class StoreCoordinator {
  final Map<String, IDataStore> _stores = {};

  void registerStore(String key, IDataStore store) {
    _stores[key] = store;
  }

  void unregisterStore(String key) {
    _stores.remove(key);
  }

  IDataStore? getStore(String key) {
    return _stores[key];
  }

  T? getStoreAs<T extends IDataStore>(String key) {
    final store = _stores[key];
    if (store is T) {
      return store;
    }
    return null;
  }

  void setLoadingOnAll() {
    for (final store in _stores.values) {
      store.setStatus(DataStoreStatus.loading);
    }
  }

  void setErrorOnAll(OperationFailure failure) {
    for (final store in _stores.values) {
      store.setError(failure);
    }
  }

  void resetAll() {
    for (final store in _stores.values) {
      store.reset();
    }
  }
}

// Example model classes for the multi-entity store
class Post extends BaseModel<Post> {
  final String id;
  final String title;
  final String content;

  const Post({required this.id, required this.title, required this.content})
    : super(id: '');

  @override
  Post copyWith() {
    throw UnimplementedError();
  }

  @override
  Post empty() {
    throw UnimplementedError();
  }

  @override
  Post fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class Category extends BaseModel<Category> {
  final String id;
  final String name;

  const Category({required this.id, required this.name}) : super(id: '');

  @override
  Category copyWith() {
    throw UnimplementedError();
  }

  @override
  Category empty() {
    throw UnimplementedError();
  }

  @override
  Category fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class UserStats extends BaseModel<UserStats> {
  final int postCount;
  final int commentCount;
  final int likeCount;

  const UserStats({
    this.postCount = 0,
    this.commentCount = 0,
    this.likeCount = 0,
    required super.id,
  });

  @override
  UserStats copyWith() {
    throw UnimplementedError();
  }

  @override
  UserStats empty() {
    throw UnimplementedError();
  }

  @override
  UserStats fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

// Example stores for the multi-entity store
class PostsStore extends CollectionStore<Post> {
  PostsStore() : super();
}

// Completing CategoriesStore class
class CategoriesStore extends CollectionStore<Category> {
  CategoriesStore() : super();
}

// Add missing UserStatsStore
class UserStatsStore extends EntityStore<UserStats> {
  UserStatsStore() : super();
}

/// Repository that works with multiple stores
abstract class IMultiStoreRepository implements IRepository {
  // Get the StoreCoordinator instance
  StoreCoordinator get storeCoordinator;

  // Utility to update a specific store
  void updateStore<T extends IDataStore>(
    String key,
    void Function(T store) updater,
  ) {
    final store = storeCoordinator.getStoreAs<T>(key);
    if (store != null) {
      updater(store);
    }
  }
}

/// Simple service locator for repositories
class RepositoryProvider {
  static final Map<Type, IRepository> _repositories = {};

  static void register<T extends IRepository>(T repository) {
    _repositories[T] = repository;
  }

  static T? get<T extends IRepository>() {
    return _repositories[T] as T?;
  }

  static void clear() {
    _repositories.clear();
  }
}

// Product model
class Product extends BaseModel<Product> {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? description;
  final String categoryId;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    this.description,
  }) : super(id: '');

  @override
  Product copyWith() {
    throw UnimplementedError();
  }

  @override
  Product empty() {
    throw UnimplementedError();
  }

  @override
  Product fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  @override
  List<Object?> get props => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

// Product repository interface
abstract class IProductRepository implements ICrudRepository<Product> {
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> getFeaturedProducts();
}

// Product store
class ProductStore extends CollectionStore<Product>
    with
        SearchableMixin<Product>,
        FilterableMixin<Product, String>,
        SortableMixin<Product> {
  ProductStore() : super();

  // Local search implementation
  void searchProducts(String query) {
    searchLocal(query, (product, query) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          (product.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    });
  }

  // Sort by different properties
  void sortByPrice({bool ascending = true}) {
    sortItems(
      by: 'price',
      ascending: ascending,
      comparator: (a, b) => a.price.compareTo(b.price),
    );
  }

  void sortByName({bool ascending = true}) {
    sortItems(
      by: 'name',
      ascending: ascending,
      comparator: (a, b) => a.name.compareTo(b.name),
    );
  }

  // Filter by category
  void filterByCategory(String categoryId) {
    applyFilter(categoryId, (product, categoryId) {
      return product.categoryId == categoryId;
    });
  }
}

// Example of a service that uses both auth and products
class ProductService {
  final ProductStore _productStore;
  final IProductRepository _productRepository;
  final AuthStore _authStore;

  ProductService({
    required ProductStore productStore,
    required IProductRepository productRepository,
    required AuthStore authStore,
  }) : _productStore = productStore,
       _productRepository = productRepository,
       _authStore = authStore;

  Future<void> loadProducts() async {
    try {
      _productStore.setStatus(DataStoreStatus.loading);

      // Check auth state before proceeding
      if (!_authStore.isLoggedIn) {
        _productStore.setError(
          OperationFailure(message: 'Authentication required to load products'),
        );
        return;
      }

      final products = await _productRepository.getAll();
      _productStore.setItems(products);
    } catch (e, stackTrace) {
      _productStore.setError(
        OperationFailure(
          message: 'Failed to load products',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> loadFeaturedProducts() async {
    try {
      _productStore.setStatus(DataStoreStatus.loading);

      final products = await _productRepository.getFeaturedProducts();
      _productStore.setItems(products);
    } catch (e, stackTrace) {
      _productStore.setError(
        OperationFailure(
          message: 'Failed to load featured products',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> filterProductsByCategory(String categoryId) async {
    try {
      _productStore.setStatus(DataStoreStatus.loading);

      final products = await _productRepository.getProductsByCategory(
        categoryId,
      );
      _productStore.setItems(products);
    } catch (e, stackTrace) {
      _productStore.setError(
        OperationFailure(
          message: 'Failed to filter products',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

// ViewModel that uses multiple stores
class HomeViewModel extends ChangeNotifier {
  final ProductStore _productStore;
  final CategoriesStore _categoryStore;
  final AuthStore _authStore;
  final ProductService _productService;

  HomeViewModel({
    required ProductStore productStore,
    required CategoriesStore categoryStore,
    required AuthStore authStore,
    required ProductService productService,
  }) : _productStore = productStore,
       _categoryStore = categoryStore,
       _authStore = authStore,
       _productService = productService {
    _productStore.addListener(_onStoreChanged);
    _categoryStore.addListener(_onStoreChanged);
    _authStore.addListener(_onStoreChanged);
  }

  // State tracking
  bool get isLoading => _productStore.isLoading || _categoryStore.isLoading;
  bool get hasError => _productStore.isError || _categoryStore.isError;
  String? get errorMessage =>
      _productStore.isError
          ? _productStore.error?.message
          : _categoryStore.isError
          ? _categoryStore.error?.message
          : null;

  List<Product> get products => _productStore.items;
  List<Category> get categories => _categoryStore.items;
  bool get isAuthenticated => _authStore.isLoggedIn;
  User? get currentUser => _authStore.entity?.user;

  void _onStoreChanged() {
    // Propagate changes from stores
    notifyListeners();
  }

  // Business logic that coordinates multiple stores
  Future<void> loadHomeData() async {
    if (!isAuthenticated) {
      // Handle unauthenticated state
      return;
    }

    // Load data from multiple services
    await Future.wait([
      _productService.loadFeaturedProducts(),
      // Add other loading operations
    ]);
  }

  void filterProductsByCategory(String categoryId) {
    _productService.filterProductsByCategory(categoryId);
  }

  void searchProducts(String query) {
    _productStore.searchProducts(query);
  }

  @override
  void dispose() {
    _productStore.removeListener(_onStoreChanged);
    _categoryStore.removeListener(_onStoreChanged);
    _authStore.removeListener(_onStoreChanged);
    super.dispose();
  }
}

// void main() {
// Create stores
// final authStore = AuthStore();
// final productStore = ProductStore();
// final categoryStore = CategoriesStore();
//
// Create repositories
// final authRepository = AuthRepository();
// final productRepository = IProductRepository();
//
// Register repositories
// RepositoryProvider.register<IAuthRepository>(authRepository);
// RepositoryProvider.register<IProductRepository>(productRepository);
//
// Create services
// final authService = AuthService(
//   authStore: authStore,
//   authRepository: authRepository,
// );
//
// final productService = ProductService(
//   productStore: productStore,
//   productRepository: productRepository,
//   authStore: authStore,
// );
//
// Create ViewModel
// final homeViewModel = HomeViewModel(
//   productStore: productStore,
//   categoryStore: categoryStore,
//   authStore: authStore,
//   productService: productService,
// );
//
/// TODO: Run the app with ViewModel in your UI
// runApp(MyApp(viewModel: homeViewModel));
// }
