// Path: frontend/lib/core/services/browser_api_io.dart

import 'dart:async';
import 'dart:io';
import 'browser_api_contract.dart';

/// Mobile/Desktop platform implementation of BrowserApi
/// Provides no-op or best-effort implementations for non-web platforms
class BrowserApiIO implements BrowserApi {
  late final StreamController<void> _visibilityController;
  late final StreamController<void> _focusController;
  
  BrowserApiIO() {
    _visibilityController = StreamController<void>.broadcast();
    _focusController = StreamController<void>.broadcast();
  }
  
  @override
  bool get isDocumentHidden => false; // Always visible on mobile/desktop
  
  @override
  Stream<void> get onVisibilityChange => _visibilityController.stream;
  
  @override
  Stream<void> get onWindowFocus => _focusController.stream;
  
  @override
  String get currentUrl => 'app://localhost/'; // Default app URL for non-web
  
  @override
  Map<String, String> get queryParameters => {}; // No query params on mobile/desktop
  
  @override
  void setTitle(String title) {
    // No-op: Mobile/desktop apps don't have changeable window titles
  }
  
  @override
  void reload() {
    // No-op: Mobile/desktop apps don't reload like web pages
  }
  
  @override
  void redirect(String url) {
    // No-op: Mobile/desktop apps don't redirect like web pages
    // Could potentially implement deep linking here if needed
  }
  
  @override
  String? getLocalStorage(String key) {
    // Could implement with shared_preferences if needed
    return null;
  }
  
  @override
  void setLocalStorage(String key, String value) {
    // Could implement with shared_preferences if needed
  }
  
  @override
  void removeLocalStorage(String key) {
    // Could implement with shared_preferences if needed
  }
  
  @override
  bool get isWebPlatform => false;
  
  @override
  bool get isMobilePlatform => Platform.isAndroid || Platform.isIOS;
  
  @override
  bool get isDesktopPlatform => 
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  
  @override
  void dispose() {
    _visibilityController.close();
    _focusController.close();
  }
  
  /// Simulate visibility change (useful for testing or app lifecycle events)
  void simulateVisibilityChange() {
    _visibilityController.add(null);
  }
  
  /// Simulate window focus (useful for testing or app lifecycle events)
  void simulateWindowFocus() {
    _focusController.add(null);
  }
}