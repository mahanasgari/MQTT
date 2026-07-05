import 'package:flutter_dotenv/flutter_dotenv.dart';

String get apiBaseUrl =>
    dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/v1';

String get wsBaseUrl => apiBaseUrl.replaceFirst('http', 'ws');

String get deviceApConfigureUrl =>
    dotenv.env['DEVICE_AP_CONFIGURE_URL'] ?? 'http://192.168.4.1/configure';

String get mqttBrokerHost =>
    dotenv.env['MQTT_BROKER_HOST'] ?? 'localhost';

int get mqttBrokerPort =>
    int.tryParse(dotenv.env['MQTT_BROKER_PORT'] ?? '1883') ?? 1883;
