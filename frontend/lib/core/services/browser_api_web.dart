// Path: frontend/lib/core/services/browser_api_web.dart

// ignore_for_file: avoid_web_libraries_in_flutter
// This file is the legitimate web implementation that needs dart:html

import 'dart:async';
import 'dart:html' as html;
import 'browser_api_contract.dart';

/// Web platform implementation of BrowserApi using dart:html
class BrowserApiWeb implements BrowserApi {
  late final StreamController<void> _visibilityController;
  late final StreamController<void> _focusController;
  late final StreamSubscription _visibilitySubscription;
  late final StreamSubscription _focusSubscription;
  
  BrowserApiWeb() {
    _visibilityController = StreamController<void>.broadcast();
    _focusController = StreamController<void>.broadcast();
    _setupEventListeners();
  }
  
  void _setupEventListeners() {
    // Setup visibility change listener
    _visibilitySubscription = html.document.onVisibilityChange.listen((_) {
      _visibilityController.add(null);
    });
    
    // Setup focus listener
    _focusSubscription = html.window.onFocus.listen((_) {
      _focusController.add(null);
    });
  }
  
  @override
  bool get isDocumentHidden => html.document.hidden ?? false;
  
  @override
  Stream<void> get onVisibilityChange => _visibilityController.stream;
  
  @override
  Stream<void> get onWindowFocus => _focusController.stream;
  
  @override
  String get currentUrl => html.window.location.href;
  
  @override
  Map<String, String> get queryParameters {
    final search = html.window.location.search;
    if (search == null || search.isEmpty || search == '?') return {};
    
    final params = <String, String>{};
    final pairs = search.substring(1).split('&');
    
    for (final pair in pairs) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        params[Uri.decodeComponent(parts[0])] = Uri.decodeComponent(parts[1]);
      }
    }
    
    return params;
  }
  
  @override
  void setTitle(String title) {
    html.document.title = title;
  }
  
  @override
  void reload() {
    html.window.location.reload();
  }
  
  @override
  void redirect(String url) {
    html.window.location.href = url;
  }
  
  @override
  String? getLocalStorage(String key) {
    try {
      return html.window.localStorage[key];
    } catch (e) {
      return null;
    }
  }
  
  @override
  void setLocalStorage(String key, String value) {
    try {
      html.window.localStorage[key] = value;
    } catch (e) {
      // localStorage might be disabled
    }
  }
  
  @override
  void removeLocalStorage(String key) {
    try {
      html.window.localStorage.remove(key);
    } catch (e) {
      // localStorage might be disabled
    }
  }
  
  @override
  bool get isWebPlatform => true;
  
  @override
  bool get isMobilePlatform => false;
  
  @override
  bool get isDesktopPlatform => false;
  
  @override
  void dispose() {
    _visibilitySubscription.cancel();
    _focusSubscription.cancel();
    _visibilityController.close();
    _focusController.close();
  }
}