import 'dart:io';

String get defaultBackendURL {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5001';
  }
  return 'http://127.0.0.1:5001';
}
