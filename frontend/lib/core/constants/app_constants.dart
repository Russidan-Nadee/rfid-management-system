class AppConstants {
  // App Info
  static const String appName = 'Asset Management';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  static const String rememberLoginKey = 'remember_login';
  static const String themeKey = 'app_theme';

  // Asset Status
  static const String statusCreated = 'C';
  static const String statusActive = 'A';
  static const String statusInactive = 'I';

  static const Map<String, String> statusLabels = {
    statusCreated: 'Created',
    statusActive: 'Active',
    statusInactive: 'Inactive',
  };

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleUser = 'user';

  static const Map<String, String> roleLabels = {
    roleAdmin: 'Administrator',
    roleManager: 'Manager',
    roleUser: 'User',
  };

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 1000;

  // UI Constants
  static const double borderRadius = 8.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String unknownError = 'An unexpected error occurred';
  static const String authError = 'Authentication failed';
  static const String validationError = 'Please check your input';
}
