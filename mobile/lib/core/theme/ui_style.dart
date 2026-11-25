/// Visual skins. Classic = current Material look (always kept).
/// Mist = soft-void warm list UI (new). Toggle anytime; nothing is deleted.
enum AppUiStyle {
  classic,
  mist,
}

extension AppUiStyleX on AppUiStyle {
  String get storageValue => name;

  static AppUiStyle fromStorage(String? raw) {
    if (raw == AppUiStyle.mist.name) return AppUiStyle.mist;
    return AppUiStyle.classic;
  }
}
