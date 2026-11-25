import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/ui_style.dart';

const _uiStyleKey = 'app_ui_style_v1';

/// Classic is the shipped look. Mist remains in theme files but is not active.
class UiStyleNotifier extends Notifier<AppUiStyle> {
  @override
  AppUiStyle build() {
    _pinClassic();
    return AppUiStyle.classic;
  }

  Future<void> _pinClassic() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uiStyleKey, AppUiStyle.classic.storageValue);
    if (state != AppUiStyle.classic) {
      state = AppUiStyle.classic;
    }
  }

  Future<void> setStyle(AppUiStyle _) async {
    // Mist experiments are parked; always Classic until explicitly revived.
    state = AppUiStyle.classic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uiStyleKey, AppUiStyle.classic.storageValue);
  }
}

final uiStyleProvider =
    NotifierProvider<UiStyleNotifier, AppUiStyle>(UiStyleNotifier.new);
