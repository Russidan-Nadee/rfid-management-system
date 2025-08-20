# Browser API Platform Abstraction

This directory implements a sustainable platform abstraction pattern for web-specific functionality in Flutter applications.

## Architecture

### 1. Contract Interface (`browser_api_contract.dart`)
- Defines the `BrowserApi` abstract class
- Declares all methods needed for browser-specific functionality
- Platform-agnostic interface that app code can depend on

### 2. Platform Implementations
- **`browser_api_web.dart`**: Uses `dart:html` for web platform
- **`browser_api_io.dart`**: No-op/best-effort implementation for mobile/desktop

### 3. Factory Pattern (`browser_api_factory_*.dart`)
- **`browser_api_factory_web.dart`**: Creates web implementation
- **`browser_api_factory_io.dart`**: Creates mobile/desktop implementation

### 4. Conditional Exports (`browser_api.dart`)
- Uses conditional imports to select the correct factory at compile time
- Provides singleton service `BrowserApiService` for easy access
- Eliminates runtime platform checks for imports

## Benefits

✅ **Compile-time platform selection**: No `dart:html` imports on mobile/desktop
✅ **Type safety**: All platforms use the same interface
✅ **Testability**: Easy to mock with custom implementations
✅ **Maintainability**: Clear separation of platform-specific code
✅ **Lint enforcement**: `avoid_web_libraries_in_flutter` prevents direct usage

## Usage

### Basic Usage
```dart
import '../core/services/browser_api.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late BrowserApi _browserApi;
  StreamSubscription<void>? _focusSubscription;

  @override
  void initState() {
    super.initState();
    _browserApi = BrowserApiService.instance;
    
    // Listen for window focus events (works on all platforms)
    _focusSubscription = _browserApi.onWindowFocus.listen((_) {
      // Handle focus event
    });
  }

  @override
  void dispose() {
    _focusSubscription?.cancel();
    super.dispose();
  }
}
```

### Platform Detection
```dart
void someMethod() {
  final browserApi = BrowserApiService.instance;
  
  if (browserApi.isWebPlatform) {
    // Web-specific logic
  } else if (browserApi.isMobilePlatform) {
    // Mobile-specific logic
  } else if (browserApi.isDesktopPlatform) {
    // Desktop-specific logic
  }
}
```

### Testing
```dart
class MockBrowserApi implements BrowserApi {
  // Implement all methods for testing
}

// In tests
BrowserApiService.initialize(MockBrowserApi());
```

## Migration Guide

### Before (❌ Direct web library usage)
```dart
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  html.window.onFocus.listen((event) {
    // Handle focus
  });
}
```

### After (✅ Platform abstraction)
```dart
import '../core/services/browser_api.dart';

final browserApi = BrowserApiService.instance;
browserApi.onWindowFocus.listen((_) {
  // Handle focus - works on all platforms
});
```

## Lint Rules

The following lint rule is enforced to prevent regression:

```yaml
# analysis_options.yaml
linter:
  rules:
    avoid_web_libraries_in_flutter: true
```

This prevents direct imports of `dart:html`, `dart:js`, etc. in Flutter applications.

## File Structure

```
lib/core/services/
├── browser_api_contract.dart         # Abstract interface
├── browser_api_web.dart             # Web implementation (uses dart:html)
├── browser_api_io.dart              # Mobile/Desktop implementation
├── browser_api_factory_web.dart     # Web factory
├── browser_api_factory_io.dart      # Mobile/Desktop factory
├── browser_api.dart                 # Conditional exports & service
└── README_browser_api.md           # This documentation
```

## Supported Features

- ✅ Document visibility changes
- ✅ Window focus events
- ✅ URL and query parameters access
- ✅ Page title management
- ✅ Local storage operations
- ✅ Platform detection
- ✅ Page navigation (reload/redirect)

## Adding New Features

1. Add method to `BrowserApi` interface in `browser_api_contract.dart`
2. Implement in `browser_api_web.dart` using web APIs
3. Provide no-op or alternative implementation in `browser_api_io.dart`
4. Update this documentation

This pattern ensures your Flutter app remains cross-platform while safely using web-specific APIs where needed.