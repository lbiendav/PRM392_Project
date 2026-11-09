class AppConstants {
  AppConstants._();

  // App Metadata
  static const String appName = 'CoffeeCraft';
  static const String appTagline = 'Hương vị cà phê nguyên bản mỗi ngày';

  // SharedPreferences Keys
  static const String keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String keyRememberMe = 'remember_me';
  static const String keySavedEmail = 'saved_email';
  static const String keySavedPassword = 'saved_password';
  static const String keyThemeMode = 'theme_mode'; // 'light', 'dark', 'system'
  static const String keySearchHistory = 'search_history';
  static const String keyCatalogBranchId = 'catalog_branch_id';

  // Firestore Collections
  static const String colUsers = 'users';
  static const String colProducts = 'products';
  static const String colBranches = 'branches';
  static const String colCategories = 'categories';
  static const String colOrders = 'orders';
  static const String colVouchers = 'vouchers';
  static const String colAddresses = 'addresses';
  static const String colReviews = 'reviews';
  static const String colNotifications = 'notifications';
  static const String colFeedbacks = 'feedbacks';

  // Firebase Storage Buckets / Folders
  static const String storageAvatars = 'avatars';
  static const String storageProducts = 'products';
}
