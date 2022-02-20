import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:mono_story/constants.dart';
import 'package:mono_story/models/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  Settings settings = Settings();

  Future<SettingsViewModel> init() async {
    Map<String, dynamic> settingsJson = settings.toJson();
    for (String k in settingsJson.keys) {
      settingsJson[k] = await _getSettings(k);
      developer.log('Init Settings: ( $k, ${settingsJson[k]} )');
    }
    settings = Settings.fromJson(settingsJson);
    return this;
  }

  Future<dynamic> _getSettings(String key) async {
    if (key == SettingsKeys.useCellularData) {
      return await getUseCellularData();
    }
    return null;
  }

  Future<bool?> getUseCellularData() async {
    final prefs = await SharedPreferences.getInstance();
    settings.useCellularData ??= prefs.getBool(SettingsKeys.useCellularData);
    developer.log('useCellularData: ${settings.useCellularData}');
    return settings.useCellularData;
  }

  Future<bool> setUseCellularData(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    bool ret = await prefs.setBool(SettingsKeys.useCellularData, value);
    if (ret == false) {
      developer.log(
        'setUseCellularData',
        error: 'Failed to set useCellularData to $value',
      );
      return false;
    }
    settings.useCellularData = value;
    developer.log('useCellularData is set to ${settings.useCellularData}');
    return ret;
  }
}
