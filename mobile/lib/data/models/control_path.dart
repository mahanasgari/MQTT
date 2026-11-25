enum ControlPath { softAp, lan, cloud }

extension ControlPathLabel on ControlPath {
  String get label {
    switch (this) {
      case ControlPath.softAp:
        return 'Direct (device Wi‑Fi)';
      case ControlPath.lan:
        return 'Local network';
      case ControlPath.cloud:
        return 'Internet';
    }
  }
}

class ControlResult {
  final ControlPath path;
  final String power;

  const ControlResult({required this.path, required this.power});
}
