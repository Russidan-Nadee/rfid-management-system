// Path: frontend/lib/core/services/browser_api_web.dart

// ignore_for_file: avoid_web_libraries_in_flutter
// This file is the legitimate web implementation that uses package:web

import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'browser_api_contract.dart';

/// Web platform implementation of BrowserApi using package:web
class BrowserApiWeb implements BrowserApi {
  late final StreamController<void> _visibilityController;
  late final StreamController<void> _focusController;
  
  BrowserApiWeb() {
    _visibilityController = StreamController<void>.broadcast();
    _focusController = StreamController<void>.broadcast();
    _setupEventListeners();
  }
  
  void _setupEventListeners() {
    // Setup visibility change listener
    web.document.addEventListener('visibilitychange', _handleVisibilityChange.toJS);
    
    // Setup focus listener  
    web.window.addEventListener('focus', _handleFocus.toJS);
  }
  
  void _handleVisibilityChange(web.Event event) {
    _visibilityController.add(null);
  }
  
  void _handleFocus(web.Event event) {
    _focusController.add(null);
  }
  
  @override
  bool get isDocumentHidden => web.document.hidden;
  
  @override
  Stream<void> get onVisibilityChange => _visibilityController.stream;
  
  @override
  Stream<void> get onWindowFocus => _focusController.stream;
  
  @override
  String get currentUrl => web.window.location.href;
  
  @override
  Map<String, String> get queryParameters {
    final search = web.window.location.search;
    if (search.isEmpty || search == '?') return {};
    
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
    web.document.title = title;
  }
  
  @override
  void reload() {
    web.window.location.reload();
  }
  
  @override
  void redirect(String url) {
    web.window.location.href = url;
  }
  
  @override
  String? getLocalStorage(String key) {
    try {
      return web.window.localStorage.getItem(key);
    } catch (e) {
      return null;
    }
  }
  
  @override
  void setLocalStorage(String key, String value) {
    try {
      web.window.localStorage.setItem(key, value);
    } catch (e) {
      // localStorage might be disabled
    }
  }
  
  @override
  void removeLocalStorage(String key) {
    try {
      web.window.localStorage.removeItem(key);
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
    // Remove event listeners
    web.document.removeEventListener('visibilitychange', _handleVisibilityChange.toJS);
    web.window.removeEventListener('focus', _handleFocus.toJS);
    
    // Close stream controllers
    _visibilityController.close();
    _focusController.close();
  }
}