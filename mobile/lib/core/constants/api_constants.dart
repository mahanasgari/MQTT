import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'device_endpoints.dart';
export 'device_endpoints.dart';

String get apiBaseUrl =>
    dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/v1';

String get wsBaseUrl => apiBaseUrl.replaceFirst('http', 'ws');

/// Legacy alias — SoftAP setup uses `/v1/setup` via [DeviceHttpClient].
@Deprecated('Use softApBaseUrl + DeviceHttpPaths.setup')
String get deviceApConfigureUrl =>
    dotenv.env['DEVICE_AP_CONFIGURE_URL'] ?? 'http://192.168.4.1/v1/setup';

@Deprecated('Use sellerMqttHost')
String get mqttBrokerHost => sellerMqttHost;

@Deprecated('Use sellerMqttPort')
int get mqttBrokerPort => sellerMqttPort;
