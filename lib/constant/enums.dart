
enum ViewModelPageStatus {
  /// 页面加载中
  loading,

  /// 页面加载完成
  loaded,

  /// 页面加载失败
  error,
}

enum Gender { male, female }

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  otpRequired,
  resendOtp,
}

enum NetworkCallStatus {
  /// 网络请求未开始
  initial,

  /// 网络请求中
  loading,

  /// 网络请求成功
  success,

  /// 网络请求失败
  failure,

  /// 未知状态
  unknown,
}