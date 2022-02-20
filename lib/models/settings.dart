import 'package:json_annotation/json_annotation.dart';
import 'package:mono_story/constants.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings {
  @JsonKey(name: SettingsKeys.useCellularData)
  bool? useCellularData;

  Settings({this.useCellularData});

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
