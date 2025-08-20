// Path: frontend/lib/core/services/browser_api_contract.dart

/// Abstract interface for browser-specific functionality
/// This contract allows platform-specific implementations without direct web dependencies
abstract class BrowserApi {
  /// Document visibility management
  bool get isDocumentHidden;
  Stream<void> get onVisibilityChange;
  
  /// Window focus management
  Stream<void> get onWindowFocus;
  
  /// URL and navigation
  String get currentUrl;
  Map<String, String> get queryParameters;
  void setTitle(String title);
  
  /// Page lifecycle
  void reload();
  void redirect(String url);
  
  /// Storage operations (if needed)
  String? getLocalStorage(String key);
  void setLocalStorage(String key, String value);
  void removeLocalStorage(String key);
  
  /// Platform detection
  bool get isWebPlatform;
  bool get isMobilePlatform;
  bool get isDesktopPlatform;
  
  /// Cleanup resources
  void dispose();
}

/// Event types for browser events
enum BrowserEventType {
  visibilityChange,
  windowFocus,
  pageLoad,
  beforeUnload,
}

/// Browser event data
class BrowserEvent {
  final BrowserEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  const BrowserEvent({
    required this.type,
    this.data = const {},
    required this.timestamp,
  });
  
  factory BrowserEvent.visibilityChange({required bool isHidden}) {
    return BrowserEvent(
      type: BrowserEventType.visibilityChange,
      data: {'isHidden': isHidden},
      timestamp: DateTime.now(),
    );
  }
  
  factory BrowserEvent.windowFocus() {
    return BrowserEvent(
      type: BrowserEventType.windowFocus,
      timestamp: DateTime.now(),
    );
  }
}