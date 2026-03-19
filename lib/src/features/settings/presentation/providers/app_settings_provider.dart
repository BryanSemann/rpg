import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({required this.autoTranslateEnabled});

  final bool autoTranslateEnabled;

  AppSettings copyWith({bool? autoTranslateEnabled}) {
    return AppSettings(
      autoTranslateEnabled:
          autoTranslateEnabled ?? this.autoTranslateEnabled,
    );
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

final autoTranslateEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).maybeWhen(
    data: (settings) => settings.autoTranslateEnabled,
    orElse: () => true,
  );
});

class AppSettingsController extends AsyncNotifier<AppSettings> {
  static const _autoTranslateKey = 'auto_translate_enabled';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      autoTranslateEnabled: prefs.getBool(_autoTranslateKey) ?? true,
    );
  }

  Future<void> setAutoTranslateEnabled(bool enabled) async {
    final current = state.valueOrNull ??
        AppSettings(autoTranslateEnabled: enabled);
    state = AsyncData(current.copyWith(autoTranslateEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoTranslateKey, enabled);
  }
}
