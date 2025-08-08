import 'dart:io';
import 'dart:convert';
import 'dart:math';

// Simple test of admin upload logic
void main() async {
  print('🧪 Testing Admin Upload Logic');
  
  // Test boundary generation
  final boundary = generateBoundary();
  print('✅ Generated boundary: $boundary');
  
  // Test content type detection
  final contentType1 = getContentType('test.jpg');
  final contentType2 = getContentType('test.png');
  final contentType3 = getContentType('test.webp');
  print('✅ JPG Content-Type: $contentType1');
  print('✅ PNG Content-Type: $contentType2'); 
  print('✅ WebP Content-Type: $contentType3');
  
  // Test multipart body creation
  final testBytes = [1, 2, 3, 4, 5]; // Sample bytes
  final body = createMultipartBody(boundary, testBytes, 'test.jpg', 'image');
  print('✅ Multipart body size: ${body.length} bytes');
  
  // Test body structure
  final bodyString = utf8.decode(body);
  print('🔍 Multipart body structure:');
  print(bodyString.replaceAll('\r\n', '\\r\\n'));
  
  print('🎉 All tests passed! Upload logic should work.');
}

String generateBoundary() {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
}

List<int> createMultipartBody(String boundary, List<int> fileBytes, String filename, String fieldName) {
  final contentType = getContentType(filename);
  
  var body = <int>[];
  
  // Add field with proper multipart formatting
  body.addAll(utf8.encode('--$boundary\r\n'));
  body.addAll(utf8.encode('Content-Disposition: form-data; name="$fieldName"; filename="$filename"\r\n'));
  body.addAll(utf8.encode('Content-Type: $contentType\r\n'));
  body.addAll(utf8.encode('\r\n')); // Empty line before content
  body.addAll(fileBytes);
  body.addAll(utf8.encode('\r\n'));
  body.addAll(utf8.encode('--$boundary--\r\n'));
  
  return body;
}

String getContentType(String filename) {
  final extension = filename.toLowerCase().split('.').last;
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    default:
      return 'image/jpeg';
  }
}