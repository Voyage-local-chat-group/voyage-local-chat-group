import 'backend_config_stub.dart' if (dart.library.io) 'backend_config_io.dart';

const _configuredBackendURL = String.fromEnvironment('BACKEND_URL');

String get backendURL {
  if (_configuredBackendURL.isNotEmpty) {
    return _configuredBackendURL;
  }
  return defaultBackendURL;
}
