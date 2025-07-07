[//]: # (ApiResponse)
# Implementation


```dart
import 'package:pack/pack.dart';
import '../merchant/merchant.dart';
import '../product/products_model.dart';
import '../merchant/merchant_service_model.dart';

// Refactored MerchantLoginResponse using the new base class
class MerchantLoginResponse extends MultiStateApiResponse<MerchantData, Map<String, dynamic>> {
  MerchantLoginResponse._({
    required super.status,
    required super.message,
    required super.success,
    required super.state,
    super.data,
    super.error,
    super.rawData,
    required super.timestamp,
  });

  // Factory for success response
  factory MerchantLoginResponse.success({
    required int status,
    required String message,
    required MerchantData data,
    required String timestamp,
  }) {
    return MerchantLoginResponse._(
      status: status,
      message: message,
      success: true,
      state: ResponseState.success,
      data: data,
      timestamp: timestamp,
    );
  }

  // Factory for OTP required response (intermediate state)
  factory MerchantLoginResponse.otpRequired({
    required int status,
    required String message,
    required Map<String, dynamic> data, // Contains merchant_id and otp
    required String timestamp,
  }) {
    return MerchantLoginResponse._(
      status: status,
      message: message,
      success: true,
      state: ResponseState.intermediate,
      rawData: data,
      timestamp: timestamp,
    );
  }

  // Factory for error response
  factory MerchantLoginResponse.error({
    required int status,
    required String message,
    Map<String, dynamic>? data,
    required String timestamp,
  }) {
    return MerchantLoginResponse._(
      status: status,
      message: message,
      success: false,
      state: ResponseState.error,
      error: data,
      timestamp: timestamp,
    );
  }

  // Factory constructor to parse JSON
  factory MerchantLoginResponse.fromJson(Map<String, dynamic> json) {
    dev.log('JSON: $json');
    final status = json.getInt('status');
    final message = json.getString('message');
    final data = json['data'] != null ? Map<String, dynamic>.from(json['data']) : null;
    final timestamp = json.getString('timestamp');

    if (status == 200) {
      return MerchantLoginResponse.success(
        status: status,
        message: message,
        data: MerchantData(
          merchant: MerchantModel.fromJson(data!['merchant']),
          subscription: MerchantSubscriptionModel.fromJson(data['subscription']),
        ),
        timestamp: timestamp,
      );
    } else if (status == 201) {
      return MerchantLoginResponse.otpRequired(
        status: status,
        message: message,
        data: data!,
        timestamp: timestamp,
      );
    } else {
      return MerchantLoginResponse.error(
        status: status,
        message: message,
        data: data,
        timestamp: timestamp,
      );
    }
  }
}

// Refactored SubmitServiceResponse
class SubmitServiceResponse extends DataItemApiResponse<MerchantServiceModel> {
  final String? serviceId; // Used for delete operations

  SubmitServiceResponse({
    required super.status,
    required super.message,
    required super.success,
    super.data,
    this.serviceId,
    required super.timestamp,
  });

  factory SubmitServiceResponse.fromJson(Map<String, dynamic> json) {
    return SubmitServiceResponse(
      status: json.getInt('status', 200),
      message: json.getString('message'),
      success: json.getBool('success'),
      data: json['data']?['service'] != null 
          ? MerchantServiceModel.fromJson(json['data']['service']) 
          : null,
      serviceId: json['data']?['service_id']?.toString(),
      timestamp: json.getString('timestamp', DateTime.now().toIso8601String()),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    if (serviceId != null) {
      (baseJson['data'] as Map<String, dynamic>?)?['service_id'] = serviceId;
    }
    return baseJson;
  }
}

// Refactored EadProductResponse
class EadProductResponse extends DataListApiResponse<ProductModel> {
  EadProductResponse({
    required super.status,
    required super.message,
    required super.success,
    required super.items,
    required super.count,
    required super.timestamp,
  });

  factory EadProductResponse.fromJson(Map<String, dynamic> json) {
    final products = (json.get('data', []) as List<dynamic>)
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
        
    return EadProductResponse(
      status: json.getInt('status', 200),
      message: json.getString('message', ''),
      success: json.getString('status') == 'success',
      items: products,
      count: json.getInt('count', products.length),
      timestamp: json.getString('timestamp', DateTime.now().toIso8601String()),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    baseJson['data'] = items.map((product) => product.toJson()).toList();
    return baseJson;
  }
}
```

```dart
import 'package:dartz/dartz.dart';
import '../../failure/src/network_failure.dart';

class MerchantRepository {
  final ApiCallService _apiService;

  MerchantRepository(this._apiService);

  // Example: Login with proper response handling
  Future<Either<NetworkFailure, MerchantLoginResponse>> login(
      String email,
      String password,
      ) async {
    final config = RequestConfig(
      baseUrl: 'https://api.example.com',
      endpoint: '/merchant/login',
      method: RequestMethod.post,
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );

    return _apiService.requestWithResponseType<MerchantLoginResponse>(
      config: config,
      responseConverter: MerchantLoginResponse.fromJson,
    );
  }

  // Example: Get products with list response handling
  Future<Either<NetworkFailure, EadProductResponse>> getProducts() async {
    final config = RequestConfig(
      baseUrl: 'https://api.example.com',
      endpoint: '/products',
      method: RequestMethod.get,
      requiresAuth: true,
      cachePolicy: CachePolicy.cacheFirst,
      cacheDuration: Duration(minutes: 15),
    );

    return _apiService.requestWithResponseType<EadProductResponse>(
      config: config,
      responseConverter: EadProductResponse.fromJson,
    );
  }

  // Example: Submit a service
  Future<Either<NetworkFailure, SubmitServiceResponse>> submitService(
      MerchantServiceModel service,
      ) async {
    final config = RequestConfig(
      baseUrl: 'https://api.example.com',
      endpoint: '/merchant/services',
      method: RequestMethod.post,
      body: service.toJson(),
      requiresAuth: true,
    );

    return _apiService.requestWithResponseType<SubmitServiceResponse>(
      config: config,
      responseConverter: SubmitServiceResponse.fromJson,
    );
  }

  // Example using the generic list helper
  Future<Either<NetworkFailure, DataListApiResponse<ProductModel>>> getProductsGeneric() async {
    final config = RequestConfig(
      baseUrl: 'https://api.example.com',
      endpoint: '/products',
      method: RequestMethod.get,
      requiresAuth: true,
    );

    return _apiService.requestList<ProductModel>(
      config: config,
      itemConverter: ProductModel.fromJson,
    );
  }
}

// Example of using the response in a UI component
class LoginScreenController {
  final MerchantRepository _repository;

  LoginScreenController(this._repository);

  Future<void> login(String email, String password) async {
    final result = await _repository.login(email, password);

    result.fold(
          (failure) {
        // Handle network failure
        showError(failure.message);
      },
          (response) {
        // Use the when helper for state handling
        response.when(
          success: (merchantData) {
            // Navigate to dashboard
            navigateToDashboard(merchantData);
          },
          error: (errorData) {
            // Show error message
            showError(response.message);
          },
          intermediate: (data) {
            // Handle OTP flow
            final merchantId = data?['merchant_id'];
            final otp = data?['otp'];
            navigateToOtpScreen(merchantId, otp);
          },
        );
      },
    );
  }

  // UI helper methods
  void showError(String message) {
    // Show error dialog or snackbar
  }

  void navigateToDashboard(MerchantData data) {
    // Navigate to dashboard screen
  }

  void navigateToOtpScreen(String? merchantId, String? otp) {
    // Navigate to OTP verification screen
  }
}

```